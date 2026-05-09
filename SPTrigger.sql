
-- Trigger tính số ngày nghỉ thực tế
CREATE TRIGGER trg_CalculateSoNgayNghiThucTe
ON dbo.DonNghiPhep
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ tính toán nếu có sự thay đổi về ngày hoặc đơn mới
    IF UPDATE(NgayBatDau) OR UPDATE(NgayKetThuc)
    BEGIN
        UPDATE dnp
        SET dnp.SoNgayNghi = (
            SELECT COUNT(*) 
            FROM dbo.ChiTietLoaiNgay ln 
            WHERE ln.Ngay BETWEEN i.NgayBatDau AND i.NgayKetThuc
            AND ln.MaHS = 'HS001' -- Chỉ đếm ngày thường, bỏ qua thứ 7, CN, Lễ
        )
        FROM dbo.DonNghiPhep dnp
        INNER JOIN inserted i ON dnp.MaDon = i.MaDon;
    END
END;
-- Trigger chống nghỉ quá số ngày phép (Chỉ với nghỉ phép năm)
CREATE OR ALTER TRIGGER trg_KiemTraSoNgayNghi
ON dbo.DonNghiPhep
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN dbo.QuyPhep qp ON i.MaNV = qp.MaNV AND YEAR(i.NgayBatDau) = qp.Nam
        WHERE i.MaLoaiPhep = 'AL' 
        AND (qp.TongPhepDuocNghi - qp.SoNgayDaNghi) < i.SoNgayNghi
    )
    BEGIN
        RAISERROR (N'Lỗi: Nhân viên không đủ ngày phép còn lại để thực hiện đơn này!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
-- Trigger tính thâm niên để cộng thêm phép vào tổng ngày phép
CREATE OR ALTER TRIGGER trg_UpdateQuyPhepThamNien
ON dbo.QuyPhep
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE qp
    SET qp.TongPhepDuocNghi = 12 + (DATEDIFF(YEAR, hd.NgayBatDau, GETDATE()) / 5)
    FROM dbo.QuyPhep qp
    INNER JOIN inserted i ON qp.MaQuyPhep = i.MaQuyPhep
    INNER JOIN dbo.HopDong hd ON i.MaNV = hd.MaNV
    WHERE qp.Nam = YEAR(GETDATE());
END;
--Tạo trigger trừ quỹ phép
 
CREATE OR ALTER TRIGGER trg_UpdateQuyPhep_Final
ON dbo.DonNghiPhep
AFTER UPDATE, INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- TRƯỜNG HỢP 1: Đơn mới được thêm vào và đã ở trạng thái 'Thành công'
    -- (Hoặc cập nhật trạng thái từ 'Chờ duyệt' -> 'Thành công')
    IF EXISTS (SELECT * FROM inserted i 
               LEFT JOIN deleted d ON i.MaDon = d.MaDon
               WHERE i.TrangThai = N'Thành công' 
               AND (d.TrangThai IS NULL OR d.TrangThai <> N'Thành công'))
    BEGIN
        UPDATE qp
        SET qp.SoNgayDaNghi = qp.SoNgayDaNghi + i.SoNgayNghi
        FROM dbo.QuyPhep qp
        INNER JOIN inserted i ON qp.MaNV = i.MaNV
        WHERE qp.Nam = YEAR(i.NgayBatDau)
        AND i.TrangThai = N'Thành công';
    END

    -- TRƯỜNG HỢP 2: Nếu đơn đang 'Thành công' mà bị hủy (Chuyển sang 'Bị từ chối' hoặc 'Chờ duyệt')
    -- Hệ thống phải hoàn trả lại ngày phép cho nhân viên
    IF EXISTS (SELECT * FROM inserted i 
               INNER JOIN deleted d ON i.MaDon = d.MaDon
               WHERE d.TrangThai = N'Thành công' 
               AND i.TrangThai <> N'Thành công')
    BEGIN
        UPDATE qp
        SET qp.SoNgayDaNghi = qp.SoNgayDaNghi - d.SoNgayNghi
        FROM dbo.QuyPhep qp
        INNER JOIN deleted d ON qp.MaNV = d.MaNV
        WHERE qp.Nam = YEAR(d.NgayBatDau);
    END
END;

-- SP tính tổng hợp công
CREATE OR ALTER PROCEDURE dbo.sp_CalculateTongHopChamCongForDate
    @TargetDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Set thời gian làm việc
    DECLARE @MorningStart TIME = '08:00:00';
    DECLARE @MorningEnd   TIME = '11:30:00';
    DECLARE @AfternoonStart TIME = '13:00:00';
    DECLARE @AfternoonEnd   TIME = '17:30:00';
    DECLARE @MinOvertimeMinutes INT = 60; -- Ít nhất 60p mới tính tăng ca

    -- Xóa dữ liệu cũ để tính lại
    DELETE FROM dbo.TongHopChamCong WHERE NgayLamViec = @TargetDate;

    ;WITH DailyCheck AS (
        SELECT
            MaNV,
            CAST(check_time AS DATE) AS NgayLamViec,
            -- Lấy giờ quẹt thẻ nhỏ nhất và lớn nhất trong ca Hành chính
            MIN(CASE WHEN LoaiCa = 'Hanh chinh' AND check_type = 'check-in' THEN check_time END) AS InHC,
            MAX(CASE WHEN LoaiCa = 'Hanh chinh' AND check_type = 'check-out' THEN check_time END) AS OutHC,
            -- Giờ tăng ca
            MIN(CASE WHEN LoaiCa = 'Tang ca' AND check_type = 'check-in' THEN check_time END) AS InTC,
            MAX(CASE WHEN LoaiCa = 'Tang ca' AND check_type = 'check-out' THEN check_time END) AS OutTC
        FROM dbo.ChamCong
        WHERE CAST(check_time AS DATE) = @TargetDate
        GROUP BY MaNV, CAST(check_time AS DATE)
    ),
    WorkIntervals AS (
        SELECT 
            dc.*,
            -- HIỆP SÁNG: Lấy khoảng giao giữa (Giờ làm thực tế) và (Giờ quy định sáng)
            DATEDIFF(MINUTE, 
                CASE WHEN CAST(dc.InHC AS TIME) > @MorningStart THEN CAST(dc.InHC AS TIME) ELSE @MorningStart END,
                CASE WHEN CAST(dc.OutHC AS TIME) < @MorningEnd THEN CAST(dc.OutHC AS TIME) ELSE @MorningEnd END
            ) AS MorningMins,
            -- HIỆP CHIỀU: Lấy khoảng giao giữa (Giờ làm thực tế) và (Giờ quy định chiều)
            DATEDIFF(MINUTE, 
                CASE WHEN CAST(dc.InHC AS TIME) > @AfternoonStart THEN CAST(dc.InHC AS TIME) ELSE @AfternoonStart END,
                CASE WHEN CAST(dc.OutHC AS TIME) < @AfternoonEnd THEN CAST(dc.OutHC AS TIME) ELSE @AfternoonEnd END
            ) AS AfternoonMins,
            -- TĂNG CA:
            DATEDIFF(MINUTE, dc.InTC, dc.OutTC) AS TCOverallMins
        FROM DailyCheck dc
    ),
    FinalCalculation AS (
        SELECT 
            wi.MaNV, wi.NgayLamViec,
            -- Tổng phút làm việc = Phút Sáng (không âm) + Phút Chiều (không âm)
            (CASE WHEN wi.MorningMins > 0 THEN wi.MorningMins ELSE 0 END + 
             CASE WHEN wi.AfternoonMins > 0 THEN wi.AfternoonMins ELSE 0 END) AS TotalWorkMins,
            ISNULL(wi.TCOverallMins, 0) AS TotalOTMins,
            -- Đi muộn: So với 08:00 sáng
            CASE WHEN CAST(wi.InHC AS TIME) > @MorningStart THEN DATEDIFF(MINUTE, @MorningStart, CAST(wi.InHC AS TIME)) ELSE 0 END AS LateMins,
            -- Về sớm: So với 17:30 chiều
            CASE WHEN CAST(wi.OutHC AS TIME) < @AfternoonEnd THEN DATEDIFF(MINUTE, CAST(wi.OutHC AS TIME), @AfternoonEnd) ELSE 0 END AS EarlyMins
        FROM WorkIntervals wi
    )
    INSERT INTO dbo.TongHopChamCong (MaNV, NgayLamViec, SoGioLam, SoGioTangCa, TrangThai, late_minutes, early_leave_minutes, MaHS)
    SELECT 
        fc.MaNV, 
        fc.NgayLamViec,
        -- Làm tròn 15 phút (0.25h) cho giờ làm chính
        CAST(ROUND(fc.TotalWorkMins / 60.0 * 4, 0) / 4 AS DECIMAL(10,2)) AS SoGioLam,
        -- Tăng ca trên 60p mới tính, cũng làm tròn 15p
        CASE WHEN fc.TotalOTMins >= @MinOvertimeMinutes 
             THEN CAST(ROUND(fc.TotalOTMins / 60.0 * 4, 0) / 4 AS DECIMAL(10,2)) ELSE 0 END AS SoGioTangCa,
        CASE WHEN fc.LateMins > 0 OR fc.EarlyMins > 0 THEN 1 ELSE 0 END,
        fc.LateMins, 
        fc.EarlyMins,
        ISNULL(ln.MaHS, 'HS001')
    FROM FinalCalculation fc
    LEFT JOIN dbo.ChiTietLoaiNgay ln ON fc.NgayLamViec = ln.Ngay;
END;
-- SP tính lương
CREATE OR ALTER PROCEDURE dbo.sp_TinhVaCapNhatBangLuong
    @KyLuongVao VARCHAR(7) -- '2026-03'
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_WARNINGS OFF;

    DECLARE @SoNgayCongChuan INT = 22;
    DECLARE @SoGioChuanThang DECIMAL(10, 2) = 176.0;
    DECLARE @NguongViPham INT = 5;
    DECLARE @MaKyLuatViPham VARCHAR(10) = 'KL01'; 
	DECLARE @MaPCThamNien VARCHAR(10) = 'PC05';

    DECLARE @KyLuong INT = CAST(REPLACE(@KyLuongVao, '-', '') AS INT);
    DECLARE @NgayBatDauKy DATE = CAST(@KyLuongVao + '-01' AS DATE);
    DECLARE @NgayKetThucKy DATE = EOMONTH(@NgayBatDauKy);

	-- 2. TỰ ĐỘNG THÊM PHỤ CẤP THÂM NIÊN VÀO BẢNG ChiTietPhuCap
    ;WITH NgayVaoLamThucTe AS (
        SELECT MaNV, MIN(NgayBatDau) AS NgayDauTien
        FROM dbo.HopDong
        GROUP BY MaNV
    )
    INSERT INTO dbo.ChiTietPhuCap (MaNV, MaPhuCap, NgayNhan)
    SELECT nvl.MaNV, @MaPCThamNien, @NgayKetThucKy
    FROM NgayVaoLamThucTe nvl
    WHERE DATEDIFF(YEAR, nvl.NgayDauTien, @NgayKetThucKy) >= 5
    AND NOT EXISTS (
        SELECT 1 FROM dbo.ChiTietPhuCap ct 
        WHERE ct.MaNV = nvl.MaNV 
        AND ct.MaPhuCap = @MaPCThamNien 
        AND MONTH(ct.NgayNhan) = MONTH(@NgayKetThucKy)
        AND YEAR(ct.NgayNhan) = YEAR(@NgayKetThucKy)
    );
    -- Lấy tiền phạt vi phạm
    DECLARE @TienPhatKL01 DECIMAL(18, 2);
    SELECT @TienPhatKL01 = ISNULL(SoTienPhat, 0) FROM dbo.KyLuat WHERE MaKyLuat = @MaKyLuatViPham;

    -- XÓA DỮ LIỆU CŨ CỦA KỲ NÀY
    DELETE FROM dbo.BangLuong WHERE KiLuong = @KyLuong;

    -- BẮT ĐẦU TÍNH TOÁN
    ;WITH 
    -- 1. Hợp đồng
    HopDongHieuLuc AS (
        SELECT hd.MaNV, hd.LuongCoBan, ISNULL(hd.TroCap, 0) AS TroCapHD,
               ROW_NUMBER() OVER(PARTITION BY hd.MaNV ORDER BY hd.NgayBatDau DESC) as SttHopDong
        FROM dbo.HopDong hd
        WHERE hd.NgayBatDau <= @NgayKetThucKy AND (hd.NgayKetThuc IS NULL OR hd.NgayKetThuc >= @NgayBatDauKy)
    ),
    -- 2. Chấm công
    CongThang AS (
        SELECT thcc.MaNV,
               SUM(ISNULL(thcc.SoGioLam, 0)) / 8.0 AS TinhSoNgayLamViec,
               SUM(ISNULL(thcc.SoGioLam, 0)) AS TongGioLamViec,
               SUM(ISNULL(thcc.SoGioTangCa, 0)) AS TongGioTangCaGoc,
               COUNT(CASE WHEN thcc.late_minutes > 0 THEN 1 END) AS TinhSoNgayDiMuon,
               COUNT(CASE WHEN thcc.early_leave_minutes > 0 THEN 1 END) AS TinhSoNgayVeSom
        FROM dbo.TongHopChamCong thcc
        WHERE thcc.NgayLamViec BETWEEN @NgayBatDauKy AND @NgayKetThucKy
        GROUP BY thcc.MaNV
    ),
    -- 3. Tăng ca
    TongLuongTangCaThang AS (
        SELECT thcc.MaNV,
               SUM(thcc.SoGioTangCa * ISNULL(hstc.HeSo, 1.0) * (hdhl.LuongCoBan / @SoGioChuanThang)) AS TinhTongLuongTangCa
        FROM dbo.TongHopChamCong thcc
        JOIN HopDongHieuLuc hdhl ON thcc.MaNV = hdhl.MaNV AND hdhl.SttHopDong = 1
        LEFT JOIN dbo.HeSoTangCa hstc ON thcc.MaHS = hstc.MaHS
        WHERE thcc.NgayLamViec BETWEEN @NgayBatDauKy AND @NgayKetThucKy GROUP BY thcc.MaNV
    ),
    -- 4. Khen thưởng
    TongKhenThuongThang AS (
        SELECT ctkt.MaNV, SUM(ISNULL(kt.SoTienThuong, 0)) AS TongTienThuong
        FROM dbo.ChiTietKhenThuong ctkt JOIN dbo.KhenThuong kt ON ctkt.MaKhenThuong = kt.MaKhenThuong
        WHERE ctkt.NgayKhenThuong BETWEEN @NgayBatDauKy AND @NgayKetThucKy GROUP BY ctkt.MaNV
    ),
    -- 5. Kỷ luật
    TongKyLuatGhiNhanThang AS (
        SELECT ctkl.MaNV, SUM(ISNULL(kl.SoTienPhat, 0)) AS TongTienPhatGhiNhan
        FROM dbo.ChiTietKyLuat ctkl JOIN dbo.KyLuat kl ON ctkl.MaKyLuat = kl.MaKyLuat
        WHERE ctkl.NgayKyLuat BETWEEN @NgayBatDauKy AND @NgayKetThucKy GROUP BY ctkl.MaNV
    ),
    -- 6. Phụ cấp (ĐOẠN NÀY LÚC NÃY THIẾU NÈ)
    TongPhuCapDacBietThang AS (
        SELECT ctpc.MaNV, SUM(ISNULL(pc.SoTienPhuCap, 0)) AS TongTienPhuCapDB
        FROM dbo.ChiTietPhuCap ctpc JOIN dbo.PhuCap pc ON ctpc.MaPhuCap = pc.MaPhuCap
        WHERE ctpc.NgayNhan BETWEEN @NgayBatDauKy AND @NgayKetThucKy GROUP BY ctpc.MaNV
    ),
    -- 7. Bảo hiểm
    TienBaoHiemThang AS (
        SELECT MaNV, (MucDong / 100.0) AS TyLeDong FROM dbo.BaoHiem
    )

    -- CUỐI CÙNG LÀ INSERT
    INSERT INTO dbo.BangLuong (
        MaLuong, MaNV, KiLuong, SoNgayLamViec, SoGioLamViec, SoGioTangCa,
        LuongCoBan, LuongTangCa, TongKyLuat, TongTienKhenThuong, PhuCapDacBiet, ThucLinh,
        late_days, early_leave_days 
    )
    SELECT
        'ML' + RIGHT(hdhl.MaNV, 3),
        hdhl.MaNV,
        @KyLuong,
        CAST(ISNULL(thct.TinhSoNgayLamViec, 0) AS DECIMAL(5, 2)),
        CAST(ISNULL(thct.TongGioLamViec, 0) AS DECIMAL(5, 2)),
        CAST(ISNULL(thct.TongGioTangCaGoc, 0) AS DECIMAL(18, 2)),
        CAST((hdhl.LuongCoBan * ISNULL(thct.TinhSoNgayLamViec, 0)) / @SoNgayCongChuan AS DECIMAL(18, 2)),
        CAST(ISNULL(tltt.TinhTongLuongTangCa, 0.00) AS DECIMAL(18, 2)),
        CAST(ISNULL(tklgnt.TongTienPhatGhiNhan, 0.00) + (CASE WHEN ISNULL(thct.TinhSoNgayDiMuon, 0) + ISNULL(thct.TinhSoNgayVeSom, 0) > @NguongViPham THEN @TienPhatKL01 ELSE 0 END) AS DECIMAL(18, 2)),
        CAST(ISNULL(tktt.TongTienThuong, 0.00) AS DECIMAL(18, 2)),
        CAST(hdhl.TroCapHD + ISNULL(tpcdbt.TongTienPhuCapDB, 0) AS DECIMAL(18, 2)),
        -- ThucLinh
        CAST((((hdhl.LuongCoBan * ISNULL(thct.TinhSoNgayLamViec, 0)) / @SoNgayCongChuan) + ISNULL(tltt.TinhTongLuongTangCa, 0.00) + (hdhl.TroCapHD + ISNULL(tpcdbt.TongTienPhuCapDB, 0)) + ISNULL(tktt.TongTienThuong, 0.00)) 
             - (ISNULL(tklgnt.TongTienPhatGhiNhan, 0.00) + (CASE WHEN ISNULL(thct.TinhSoNgayDiMuon, 0) + ISNULL(thct.TinhSoNgayVeSom, 0) > @NguongViPham THEN @TienPhatKL01 ELSE 0 END) + (hdhl.LuongCoBan * ISNULL(tbh.TyLeDong, 0.105))) AS DECIMAL(18, 2)),
        ISNULL(thct.TinhSoNgayDiMuon, 0),
        ISNULL(thct.TinhSoNgayVeSom, 0)
    FROM HopDongHieuLuc hdhl
    LEFT JOIN CongThang thct ON hdhl.MaNV = thct.MaNV AND hdhl.SttHopDong = 1
    LEFT JOIN TongLuongTangCaThang tltt ON hdhl.MaNV = tltt.MaNV AND hdhl.SttHopDong = 1
    LEFT JOIN TongKhenThuongThang tktt ON hdhl.MaNV = tktt.MaNV AND hdhl.SttHopDong = 1
    LEFT JOIN TongKyLuatGhiNhanThang tklgnt ON hdhl.MaNV = tklgnt.MaNV AND hdhl.SttHopDong = 1
    LEFT JOIN TongPhuCapDacBietThang tpcdbt ON hdhl.MaNV = tpcdbt.MaNV AND hdhl.SttHopDong = 1
    LEFT JOIN TienBaoHiemThang tbh ON hdhl.MaNV = tbh.MaNV
    WHERE hdhl.SttHopDong = 1;
END;
-- View Thông tin nhân viên
CREATE OR ALTER VIEW vw_NhanVien AS
SELECT 
    NV.MaNV, 
    NV.HoTen, 
    NV.GioiTinh, 
    NV.NgaySinh, 
    NV.SDT,
    NV.TrangThai,
    PB.TenPhongBan, 
    CV.TenChucVu, 
    TD.TenTrinhDo,
    -- Lấy ngày vào làm (Hợp đồng đầu tiên)
    (SELECT MIN(NgayBatDau) FROM dbo.HopDong WHERE MaNV = NV.MaNV) AS NgayVaoLam,
    -- Tính số năm công tác hiện tại
    DATEDIFF(YEAR, (SELECT MIN(NgayBatDau) FROM dbo.HopDong WHERE MaNV = NV.MaNV), GETDATE()) AS SoNamCongTac
FROM NhanVien NV
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
LEFT JOIN ChucVu CV ON NV.MaChucVu = CV.MaChucVu
LEFT JOIN TrinhDo TD ON NV.MaTrinhDo = TD.MaTrinhDo;
-- Dùng View Nhân viên xem Danh sách nhân viên theo phòng ban
SELECT * 
FROM vw_NhanVien 
WHERE TenPhongBan = N'Phòng Kế toán - Tài chính' 
ORDER BY TenChucVu;
-- View báo cáo chấm công
CREATE OR ALTER VIEW vw_ChamCongChiTiet AS
SELECT 
    CC.MaCC, 
    NV.MaNV,
    NV.HoTen, 
    PB.TenPhongBan,
    CV.TenChucVu,
    -- Tách riêng ngày để dễ lọc
    CAST(CC.check_time AS DATE) AS NgayChamCong,
    -- Lấy giờ phút giây (bỏ phần miligiây cho đẹp)
    CAST(CC.check_time AS TIME(0)) AS GioChamCong,
    -- Hiển thị loại check cho chuyên nghiệp
    CASE 
        WHEN CC.check_type = 'IN' THEN N'Vào'
        WHEN CC.check_type = 'OUT' THEN N'Ra'
        ELSE CC.check_type 
    END AS TrangThai,
    -- Hiển thị thứ trong tuần (Tiếng Việt)
    CASE DATEPART(WEEKDAY, CC.check_time)
        WHEN 1 THEN N'Chủ Nhật'
        WHEN 2 THEN N'Thứ Hai'
        WHEN 3 THEN N'Thứ Ba'
        WHEN 4 THEN N'Thứ Tư'
        WHEN 5 THEN N'Thứ Năm'
        WHEN 6 THEN N'Thứ Sáu'
        WHEN 7 THEN N'Thứ Bảy'
    END AS Thu
FROM ChamCong CC
INNER JOIN NhanVien NV ON CC.MaNV = NV.MaNV
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
LEFT JOIN ChucVu CV ON NV.MaChucVu = CV.MaChucVu;
-- Báo cáo về giờ làm việc
CREATE OR ALTER VIEW vw_TongHopChamCong AS
SELECT 
    THC.MaTH, 
    NV.MaNV,
    NV.HoTen, 
    PB.TenPhongBan,
    THC.NgayLamViec,
    -- Thêm Thứ để biết có phải làm cuối tuần không
    CASE DATEPART(WEEKDAY, THC.NgayLamViec)
        WHEN 1 THEN N'Chủ Nhật'
        WHEN 2 THEN N'Thứ Hai'
        WHEN 3 THEN N'Thứ Ba'
        WHEN 4 THEN N'Thứ Tư'
        WHEN 5 THEN N'Thứ Năm'
        WHEN 6 THEN N'Thứ Sáu'
        WHEN 7 THEN N'Thứ Bảy'
    END AS Thu,
    THC.SoGioLam,
    THC.SoGioTangCa,
    ISNULL(HSC.HeSo, 1.0) AS HeSoTangCa,
    THC.late_minutes AS [Phút Đi Muộn],
    THC.early_leave_minutes AS [Phút Về Sớm],
    -- Cột ghi chú nhanh để sếp soi lỗi
    CASE 
        WHEN THC.late_minutes > 0 AND THC.early_leave_minutes > 0 THEN N'Đi muộn & Về sớm'
        WHEN THC.late_minutes > 0 THEN N'Đi muộn'
        WHEN THC.early_leave_minutes > 0 THEN N'Về sớm'
        WHEN THC.SoGioLam >= 8 THEN N'Đủ công'
        ELSE N'Thiếu công'
    END AS GhiChu
FROM TongHopChamCong THC
INNER JOIN NhanVien NV ON THC.MaNV = NV.MaNV
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
LEFT JOIN HeSoTangCa HSC ON THC.MaHS = HSC.MaHS;
-- Báo cáo bảng lương
CREATE OR ALTER VIEW vw_BangLuongChiTiet AS
SELECT 
    BL.MaLuong,
    NV.MaNV,
    NV.HoTen,
    PB.TenPhongBan,
    CV.TenChucVu,
    -- Định dạng kỳ lương từ 202603 thành 03/2026
    RIGHT(CAST(BL.KiLuong AS VARCHAR), 2) + '/' + LEFT(CAST(BL.KiLuong AS VARCHAR), 4) AS [Tháng/Năm],
    
    BL.SoNgayLamViec AS [Công],
    
    -- Định dạng tiền tệ (VND) cho dễ nhìn
    FORMAT(BL.LuongCoBan, 'N0') AS [Lương Theo Công],
    FORMAT(BL.LuongTangCa, 'N0') AS [Tiền Tăng Ca],
    FORMAT(BL.PhuCapDacBiet, 'N0') AS [Tổng Phụ Cấp],
    FORMAT(BL.TongTienKhenThuong, 'N0') AS [Thưởng],
    FORMAT(BL.TongKyLuat, 'N0') AS [Khấu Trừ & Phạt], -- Bao gồm cả Bảo hiểm
    FORMAT(BL.ThucLinh, 'N0') AS [THỰC LĨNH],
    
    -- Chỉ số kỷ luật
    BL.late_days AS [Số lần đi muộn],
    BL.early_leave_days AS [Số lần về sớm]
FROM BangLuong BL
INNER JOIN NhanVien NV ON BL.MaNV = NV.MaNV
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
LEFT JOIN ChucVu CV ON NV.MaChucVu = CV.MaChucVu;

-- Bao cáo khen thưởng, kỷ luật
CREATE OR ALTER VIEW vw_LichSuThuongPhat AS
-- 1. Lấy dữ liệu Khen thưởng
SELECT 
    NV.MaNV, 
    NV.HoTen, 
    PB.TenPhongBan,
    CTKT.NgayKhenThuong AS NgayPhatSinh,
    N'Khen Thưởng' AS LoaiSuKien,
    KT.MoTa AS NoiDung,
    KT.SoTienThuong AS SoTien,
    1 AS HeSoDau -- Số dương
FROM NhanVien NV
JOIN ChiTietKhenThuong CTKT ON NV.MaNV = CTKT.MaNV
JOIN KhenThuong KT ON CTKT.MaKhenThuong = KT.MaKhenThuong
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan

UNION ALL

-- 2. Lấy dữ liệu Kỷ luật
SELECT 
    NV.MaNV, 
    NV.HoTen, 
    PB.TenPhongBan,
    CTKL.NgayKyLuat AS NgayPhatSinh,
    N'Kỷ Luật' AS LoaiSuKien,
    KL.MoTa AS NoiDung,
    KL.SoTienPhat AS SoTien,
    -1 AS HeSoDau -- Số âm để biểu thị khoản trừ
FROM NhanVien NV
JOIN ChiTietKyLuat CTKL ON NV.MaNV = CTKL.MaNV
JOIN KyLuat KL ON CTKL.MaKyLuat = KL.MaKyLuat
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan

UNION ALL

-- 3. Lấy dữ liệu Phụ cấp phát sinh
SELECT 
    NV.MaNV, 
    NV.HoTen, 
    PB.TenPhongBan,
    CTPC.NgayNhan AS NgayPhatSinh,
    N'Phụ Cấp' AS LoaiSuKien,
    PC.MoTa AS NoiDung,
    PC.SoTienPhuCap AS SoTien,
    1 AS HeSoDau
FROM NhanVien NV
JOIN ChiTietPhuCap CTPC ON NV.MaNV = CTPC.MaNV
JOIN PhuCap PC ON CTPC.MaPhuCap = PC.MaPhuCap
LEFT JOIN PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan;
-- Báo cáo Hợp đồng sắp hết hạn
CREATE OR ALTER VIEW vw_HopDongSapHetHan AS
SELECT 
    NV.MaNV,
    NV.HoTen,
    PB.TenPhongBan,
    HD.MaHopDong,
    HD.NgayBatDau,
    HD.NgayKetThuc,
    -- Tính số ngày còn lại kể từ hôm nay
    DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) AS SoNgayConLai,
    -- Phân loại trạng thái để HR dễ xử lý
    CASE 
        WHEN DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) < 0 THEN N'Đã hết hạn'
        WHEN DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) <= 15 THEN N'Cực kỳ khẩn cấp (Dưới 15 ngày)'
        WHEN DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) <= 30 THEN N'Khẩn cấp (Dưới 30 ngày)'
        ELSE N'Sắp hết hạn (Dưới 60 ngày)'
    END AS MứcĐộCảnhBáo
FROM dbo.HopDong HD
JOIN dbo.NhanVien NV ON HD.MaNV = NV.MaNV
LEFT JOIN dbo.PhongBan PB ON NV.MaPhongBan = PB.MaPhongBan
WHERE 
    HD.NgayKetThuc IS NOT NULL -- Chỉ tính những hợp đồng có thời hạn (HĐ không thời hạn thì không hết hạn)
    AND DATEDIFF(DAY, GETDATE(), HD.NgayKetThuc) <= 60; -- Chỉ hiện những gì sắp diễn ra trong 2 tháng tới

SELECT * FROM NhanVien
-- SP cập nhật trạng thái làm việc
CREATE OR ALTER PROCEDURE sp_AutoCleanEmployeeStatus
AS
BEGIN
    -- Những người hết sạch hợp đồng hoặc hợp đồng mới nhất đã quá hạn
    UPDATE dbo.NhanVien
    SET TrangThai = N'inactive'
    WHERE MaNV IN (
        SELECT MaNV FROM dbo.HopDong 
        GROUP BY MaNV 
        HAVING MAX(NgayKetThuc) < CAST(GETDATE() AS DATE)
    ) AND TrangThai = N'active';

    -- Những người vừa được ký hợp đồng mới (gia hạn)
    UPDATE dbo.NhanVien
    SET TrangThai = N'active'
    WHERE MaNV IN (
        SELECT MaNV FROM dbo.HopDong 
        GROUP BY MaNV 
        HAVING MAX(NgayKetThuc) >= CAST(GETDATE() AS DATE) OR MAX(NgayKetThuc) IS NULL
    ) AND TrangThai = N'inactive';
END;
-- Trigger cập nhật trạng thái
CREATE OR ALTER TRIGGER trg_CapNhatTrangThaiTheoHopDong
ON dbo.HopDong
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Nếu hợp đồng mới nhất của nhân viên vẫn còn hạn -> Cập nhật thành 'Đang làm việc'
    UPDATE nv
    SET nv.TrangThai = N'active'
    FROM dbo.NhanVien nv
    JOIN (
        SELECT MaNV, MAX(NgayKetThuc) as MaxNgay 
        FROM dbo.HopDong 
        GROUP BY MaNV
    ) hd ON nv.MaNV = hd.MaNV
    INNER JOIN inserted i ON i.MaNV = nv.MaNV
    WHERE hd.MaxNgay >= CAST(GETDATE() AS DATE) OR hd.MaxNgay IS NULL;

    -- 2. Nếu hợp đồng mới nhất đã hết hạn -> Cập nhật thành 'Đã nghỉ việc'
    UPDATE nv
    SET nv.TrangThai = N'inactive'
    FROM dbo.NhanVien nv
    JOIN (
        SELECT MaNV, MAX(NgayKetThuc) as MaxNgay 
        FROM dbo.HopDong 
        GROUP BY MaNV
    ) hd ON nv.MaNV = hd.MaNV
    INNER JOIN inserted i ON i.MaNV = nv.MaNV
    WHERE hd.MaxNgay < CAST(GETDATE() AS DATE);
END;
