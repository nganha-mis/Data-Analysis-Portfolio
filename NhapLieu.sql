-- 1.Chèn Phòng Ban
USE quanlynhansubibica
GO
INSERT INTO PhongBan (MaPhongBan, TenPhongBan) VALUES 
('PB001', N'Phòng Hành chính - Nhân sự'),
('PB002', N'Phòng Kế toán - Tài Chính'),
('PB003', N'Phòng Kinh doanh - Phân phối'),
('PB004', N'Phòng Marketing & CSKH')
;
-- 2.Chèn Chức Vụ
INSERT INTO ChucVu (MaChucVu, TenChucVu) VALUES 
('CV001', N'Giám đốc'),
('CV002', N'Phó giám đốc'),
('CV003', N'Trưởng phòng'),
('CV004', N'Phó phòng'),
('CV005', N'Chuyên viên'),
('CV006', N'Nhân viên'),
('CV007', N'Thực tập sinh')
;

-- 3.Chèn Trình Độ
INSERT INTO TrinhDo (MaTrinhDo, TenTrinhDo) VALUES 
('TD001', N'Đại học'),
('TD002', N'Thạc sĩ'),
('TD003', N'Cao đẳng');

-- 4.Chèn Loại Phép 
INSERT INTO LoaiPhep (MaLoaiPhep, TenLoaiNghi, HeSoHuongLuong, SoCapDuyet, MoTa) VALUES 
('AL',  N'Nghỉ phép năm', 1.00, 2, N'Annual Leave - Nghỉ hưởng 100% lương'),
('SL',  N'Nghi ốm đau', 0.75, 1, N'Sick Leave - Hưởng lương BHXH 75%'),
('UL',  N'Nghỉ không lương', 0.00, 2, N'Unpaid Leave - Nghỉ việc riêng'),
('ML',  N'Nghỉ thai sản', 1.00, 2, N'Maternity Leave - Hưởng trợ cấp BHXH'),
('CL',  N'Nghỉ kết hôn', 1.00, 1, N'Marriage Leave - Nghỉ hưởng 100% lương (3 ngày)'),
('FL',  N'Nghỉ tang chế', 1.00, 1, N'Funeral Leave - Nghỉ hưởng 100% lương (3 ngày)'),
('PL',  N'Nghỉ chế độ nam (vợ sinh)', 1.00, 1, N'Paternity Leave - Nghỉ hưởng lương BHXH')
;
-- 5. Chèn Hệ số tăng ca
INSERT INTO HeSoTangCa (MaHS, TenLoaiNgay, HeSo) VALUES 
('HS001', 'weekday', 1.50), -- Ngày thường tăng ca x1.5
('HS002', 'weekend', 2.00), -- Cuối tuần tăng ca x2.0
('HS003', 'holiday', 3.00); -- Ngày lễ tăng ca x3.0
-- 6. Chèn phụ cấp
INSERT INTO PhuCap (MaPhuCap, MoTa, SoTienPhuCap) VALUES 
('PC01', N'Phụ cấp ăn trưa', 730000),      -- Tính theo mức 33k/bữa x 22 ngày
('PC02', N'Phụ cấp xăng xe & điện thoại', 500000),
('PC03', N'Phụ cấp độc hại (Khu sản xuất)', 1000000),
('PC04', N'Phụ cấp trách nhiệm', 2000000),  -- Dành cho Quản lý/Trưởng nhóm
('PC05', N'Phụ cấp thâm niên (Trên 5 năm)', 1500000);
--7. Chèn Khen Thưởng
INSERT INTO KhenThuong (MaKhenThuong, MoTa, SoTienThuong) VALUES 
('KT01', N'Thưởng chuyên cần (Tháng)', 300000),   -- Đi làm đủ 100% công
('KT02', N'Thưởng năng suất (KPI)', 2000000),     -- Vượt chỉ tiêu sản xuất/doanh số
('KT03', N'Thưởng sáng kiến kỹ thuật', 5000000),  -- Đóng góp cải tiến quy trình
('KT04', N'Thưởng nhân viên xuất sắc quý', 3000000),
('KT05', N'Thưởng thâm niên cuối năm', 10000000);
-- 8. Chèn kỷ luật
INSERT INTO KyLuat (MaKyLuat, MoTa, SoTienPhat) VALUES 
('KL01', N'Vi phạm giờ giấc (Đi muộn/Về sớm)', 50000), -- Phạt trừ trực tiếp
('KL02', N'Vi phạm nội quy an toàn thực phẩm', 500000), -- Rất quan trọng với Bibica
('KL03', N'Làm hư hỏng tài sản công cụ', 1000000),
('KL04', N'Nghỉ việc không phép (Tự ý bỏ ca)', 200000),
('KL05', N'Vi phạm an toàn lao động', 500000);
-- 9. Chèn Nhân viên
INSERT INTO NhanVien (MaNV, HoTen, GioiTinh, NgaySinh, SDT, MaPhongBan, MaChucVu, MaTrinhDo, TrangThai) VALUES 
('NV004', N'Trịnh Xuân Thanh', 'Nam', '1985-04-10', '0912000004', 'PB001', 'CV001', 'TD002', 'active'), -- Giám đốc
('NV005', N'Nguyễn Hoài Bảo', 'Nam', '1988-11-20', '0912000005', 'PB001', 'CV002', 'TD002', 'active'), -- Phó giám đốc
('NV006', N'Phạm Thu Trang', 'Nu', '1992-05-15', '0912000006', 'PB002', 'CV003', 'TD002', 'active'),  -- Trưởng phòng Kế toán
('NV007', N'Lê Minh Triết', 'Nam', '1994-08-22', '0912000007', 'PB003', 'CV003', 'TD001', 'active'),  -- Trưởng phòng Kinh doanh
('NV008', N'Vũ Hoàng Yến', 'Nu', '1996-01-30', '0912000008', 'PB004', 'CV004', 'TD001', 'active'),    -- Phó phòng Marketing
('NV009', N'Đỗ Hùng Dũng', 'Nam', '1995-09-12', '0912000009', 'PB003', 'CV005', 'TD001', 'active'),  -- Chuyên viên Kinh doanh
('NV010', N'Bùi Quỳnh Anh', 'Nu', '1997-03-05', '0912000010', 'PB001', 'CV005', 'TD001', 'active'),  -- Chuyên viên Nhân sự
('NV011', N'Trần Tuấn Tú', 'Nam', '1993-12-25', '0912000011', 'PB002', 'CV006', 'TD003', 'active'),  -- Nhân viên Kế toán
('NV012', N'Ngô Kiến Huy', 'Nam', '1999-07-18', '0912000012', 'PB004', 'CV006', 'TD001', 'active'),  -- Nhân viên CSKH
('NV013', N'Lương Thùy Linh', 'Nu', '2003-10-02', '0912000013', 'PB003', 'CV007', 'TD001', 'active');-- Thực tập sinh Kinh doanh

-- 10. Chèn Hợp đồng
INSERT INTO HopDong (MaHopDong, MaNV, LuongCoBan, TroCap, NgayBatDau, NgayKetThuc) VALUES 
('HD004', 'NV004', 35000000, 5000000, '2020-01-01', '2028-01-01'), -- Giám đốc
('HD005', 'NV005', 28000000, 4000000, '2020-06-01', '2027-06-01'), -- Phó GĐ
('HD006', 'NV006', 22000000, 3000000, '2021-01-01', '2028-01-01'), -- Trưởng phòng
('HD007', 'NV007', 20000000, 2500000, '2022-01-01', '2028-01-01'), -- Trưởng phòng
('HD008', 'NV008', 16000000, 2000000, '2022-05-01', '2027-05-01'), -- Phó phòng
('HD009', 'NV009', 12000000, 1000000, '2023-01-01', '2028-01-01'), -- Chuyên viên
('HD010', 'NV010', 11500000, 1000000, '2023-03-01', '2028-03-01'), -- Chuyên viên
('HD011', 'NV011', 9500000,  500000,  '2024-01-01', '2027-01-01'), -- Nhân viên
('HD012', 'NV012', 9000000,  500000,  '2024-02-01', '2027-02-01'), -- Nhân viên
('HD013', 'NV013', 5000000,  200000,  '2024-05-01', '2025-11-01'); -- Thực tập sinh
-- 11. Chèn Loại ngày
-- Dùng CTE để sinh ra 365 ngày trong năm 2026
WITH DateRange AS (
    SELECT CAST('2026-01-01' AS DATE) AS CalendarDate
    UNION ALL
    SELECT DATEADD(DAY, 1, CalendarDate)
    FROM DateRange
    WHERE CalendarDate < '2026-12-31'
)
INSERT INTO dbo.ChiTietLoaiNgay (Ngay, MaHS)
SELECT 
    CalendarDate,
    CASE 
        -- Khai báo các ngày Lễ (Ví dụ: Tết Dương Lịch, Giải Phóng, Quốc Khánh...)
        WHEN CalendarDate IN ('2026-01-01', '2026-04-30', '2026-05-01', '2026-09-02') THEN 'HS003' -- Holiday
        -- Thứ 7 (7) và Chủ Nhật (1)
        WHEN DATEPART(WEEKDAY, CalendarDate) IN (7, 1) THEN 'HS002' -- Weekend
        -- Còn lại là ngày thường
        ELSE 'HS001' -- Weekday
    END
FROM DateRange
OPTION (MAXRECURSION 366);
-- 12. Nhập Quỹ phép
INSERT INTO dbo.QuyPhep (MaNV, Nam, TongPhepDuocNghi, SoNgayDaNghi)
VALUES 
('NV004', 2026, 12, 0), ('NV005', 2026, 12, 0), ('NV006', 2026, 12, 0),
('NV007', 2026, 12, 0), ('NV008', 2026, 12, 0), ('NV009', 2026, 12, 0),
('NV010', 2026, 12, 0), ('NV011', 2026, 12, 0), ('NV012', 2026, 12, 0),
('NV013', 2026, 12, 0);
-- 13. Nhập Đơn nghỉ phép
INSERT INTO dbo.DonNghiPhep (MaDon, MaNV, MaLoaiPhep, NgayBatDau, NgayKetThuc, LyDo, TrangThai)
VALUES 
('DNP001', 'NV004', 'AL', '2026-01-05', '2026-01-07', N'Nghỉ phép gia đình', N'Thành công'),
('DNP002', 'NV006', 'SL', '2026-02-10', '2026-02-11', N'Nghỉ ốm (Sốt xuất huyết)', N'Thành công'),
('DNP003', 'NV008', 'AL', '2026-03-20', '2026-03-25', N'Về quê có việc', N'Thành công'), -- Đơn này sẽ tự trừ 2 ngày cuối tuần
('DNP005', 'NV005', 'CL', '2026-05-15', '2026-05-17', N'Nghỉ kết hôn', N'Thành công'),
('DNP007', 'NV009', 'ML', '2026-07-01', '2026-12-31', N'Nghỉ thai sản', N'Thành công'),
('DNP010', 'NV013', 'UL', '2026-10-20', '2026-10-20', N'Việc gia đình đột xuất', N'Bị từ chối');

-- 14. Nhập Bảo hiểm
ALTER TABLE BaoHiem ADD MucDong DECIMAL(5, 2) DEFAULT 10.5;
USE quanlynhansubibica
INSERT INTO dbo.BaoHiem (MaBaoHiem, MaNV, SoBaoHiem, NgayCap, ThoiHan, MucDong)
SELECT 
    nv.MaNV, 
    nv.MaNV, 
    '031' + RIGHT(nv.SDT, 7), 
    DATEADD(MONTH, 1, hd.NgayBatDau), 
    CASE 
        WHEN cv.MaChucVu IN ('CV001', 'CV002') THEN 20 
        ELSE 10 
    END,
    10.5 
FROM dbo.NhanVien nv
JOIN dbo.HopDong hd ON nv.MaNV = hd.MaNV
JOIN dbo.ChucVu cv ON nv.MaChucVu = cv.MaChucVu;
-- 15. Chèn dữ liệu chấm công 
DECLARE @StartDate DATE = '2026-03-01';
DECLARE @EndDate DATE = '2026-03-31';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Chỉ chèn dữ liệu nếu KHÔNG PHẢI Thứ 7 (7) hoặc Chủ nhật (1)
    IF DATEPART(WEEKDAY, @CurrentDate) NOT IN (1, 7)
    BEGIN
        -- Chèn giờ hành chính cho 10 nhân viên
        INSERT INTO dbo.ChamCong (MaNV, check_time, check_type, LoaiCa)
        SELECT 
            MaNV, 
            -- Check-in: Ngẫu nhiên từ 07:55 đến 08:10 (có người đi muộn)
            CAST(@CurrentDate AS DATETIME) + CAST(DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 900, '07:55:00') AS DATETIME), 
            'check-in', 
            N'Hanh chinh'
        FROM dbo.NhanVien;

        INSERT INTO dbo.ChamCong (MaNV, check_time, check_type, LoaiCa)
        SELECT 
            MaNV, 
            -- Check-out: Ngẫu nhiên từ 17:25 đến 17:40 (có người về sớm)
            CAST(@CurrentDate AS DATETIME) + CAST(DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 900, '17:25:00') AS DATETIME), 
            'check-out', 
            N'Hanh chinh'
        FROM dbo.NhanVien;

        -- Chèn Tăng ca cho 3 ông (NV004, NV007, NV009) vào các ngày Thứ 2, 4, 6
        IF DATEPART(WEEKDAY, @CurrentDate) IN (2, 4, 6)
        BEGIN
            INSERT INTO dbo.ChamCong (MaNV, check_time, check_type, LoaiCa)
            SELECT MaNV, CAST(@CurrentDate AS DATETIME) + '18:00:00', 'check-in', N'Tang ca' FROM dbo.NhanVien WHERE MaNV IN ('NV004', 'NV007', 'NV009');
            INSERT INTO dbo.ChamCong (MaNV, check_time, check_type, LoaiCa)
            SELECT MaNV, CAST(@CurrentDate AS DATETIME) + '20:00:00', 'check-out', N'Tang ca' FROM dbo.NhanVien WHERE MaNV IN ('NV004', 'NV007', 'NV009');
        END
    END
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;
-- 16. Nhập liệu chi tiết phụ cấp
-- 1. Phụ cấp ăn trưa 
INSERT INTO ChiTietPhuCap (MaNV, MaPhuCap, NgayNhan)
SELECT MaNV, 'PC01', '2026-03-31' FROM dbo.NhanVien;
-- 2. Phụ cấp trách nhiệm 
INSERT INTO ChiTietPhuCap (MaNV, MaPhuCap, NgayNhan)
VALUES 
('NV004', 'PC04', '2026-03-31'), 
('NV005', 'PC04', '2026-03-31'), 
('NV006', 'PC04', '2026-03-31'), 
('NV007', 'PC04', '2026-03-31');
-- 17. Nhập liệu Khen thướng
INSERT INTO ChiTietKhenThuong (MaNV, MaKhenThuong, NgayKhenThuong)
VALUES 
('NV004', 'KT02', '2026-03-31'), 
('NV010', 'KT01', '2026-03-31'), 
('NV012', 'KT01', '2026-03-31');
-- 18. Nhập liệu kỷ luật
INSERT INTO ChiTietKyLuat (MaNV, MaKyLuat, NgayKyLuat)
VALUES 
('NV011', 'KL01', '2026-03-15'), 
('NV013', 'KL02', '2026-03-20'); 
-- 19. Chạy tổng hợp công cho tất cả các ngày trong tháng (Ví dụ tháng 3)
DECLARE @LoopDate DATE = '2026-03-01';
DECLARE @EndDate DATE = '2026-03-31';

WHILE @LoopDate <= @EndDate
BEGIN
    -- Gọi Procedure tính công cho từng ngày một
    EXEC dbo.sp_CalculateTongHopChamCongForDate @TargetDate = @LoopDate;
    
    SET @LoopDate = DATEADD(DAY, 1, @LoopDate);
END;
-- Gọi Procedure tính lương cho tháng 3
EXEC dbo.sp_TinhVaCapNhatBangLuong @KyLuongVao = '2026-03';

-- Xem thành quả cuối cùng
SELECT * FROM dbo.BangLuong WHERE KiLuong = 202603;
SELECT * FROM BaoHiem
