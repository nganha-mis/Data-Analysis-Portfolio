-- 1. Bảng ChucVu
CREATE TABLE ChucVu (
MaChucVu VARCHAR(5) PRIMARY KEY,
TenChucVu NVARCHAR(50) NOT NULL
);
-- 2. Bảng PhongBan
CREATE TABLE PhongBan (
MaPhongBan VARCHAR(5) PRIMARY KEY,
TenPhongBan NVARCHAR(50) NOT NULL
);
-- 3. Bảng TrinhDo
CREATE TABLE TrinhDo (
MaTrinhDo VARCHAR(5) PRIMARY KEY,
TenTrinhDo NVARCHAR(50) NOT NULL
);
-- 4. Bảng NhanVien
CREATE TABLE NhanVien (
MaNV VARCHAR(5) PRIMARY KEY,
HoTen NVARCHAR(50) NOT NULL,
GioiTinh NVARCHAR(10) CHECK (GioiTinh IN ('Nam', 'Nu')),
NgaySinh DATE,
SDT VARCHAR(15),
MaPhongBan VARCHAR(5),
MaChucVu VARCHAR(5),
MaTrinhDo VARCHAR(5),
TrangThai VARCHAR(10) CHECK (TrangThai IN ('active', 'inactive')),
FOREIGN KEY (MaPhongBan) REFERENCES PhongBan(MaPhongBan),
FOREIGN KEY (MaChucVu) REFERENCES ChucVu(MaChucVu),
FOREIGN KEY (MaTrinhDo) REFERENCES TrinhDo(MaTrinhDo)
);
-- 5. Bảng HopDong
CREATE TABLE HopDong (
MaHopDong VARCHAR(5) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
LuongCoBan DECIMAL(18, 2),
TroCap DECIMAL(18, 2),
NgayBatDau DATE,
NgayKetThuc DATE,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
-- 6. Bảng BaoHiem
CREATE TABLE BaoHiem (
MaBaoHiem VARCHAR(5) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
SoBaoHiem VARCHAR(20),
NgayCap DATE,
ThoiHan INT,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
-- 7. Bảng ChamCong
CREATE TABLE ChamCong (
MaCC INT IDENTITY(1,1) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
check_time DATETIME,
check_type VARCHAR(20),
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
ALTER TABLE dbo.ChamCong 
ADD LoaiCa NVARCHAR(20) NOT NULL DEFAULT N'Hanh chinh';
-- 8. Bảng HeSoTangCa
CREATE TABLE HeSoTangCa (
MaHS VARCHAR(5) PRIMARY KEY,
TenLoaiNgay NVARCHAR(20) UNIQUE CHECK (TenLoaiNgay IN ('weekday',
'weekend', 'holiday')),
HeSo DECIMAL(5, 2)
);
-- 9. Bảng LoaiNgay
CREATE TABLE ChiTietLoaiNgay (
Ngay DATE PRIMARY KEY,
MaHS VARCHAR(5),
FOREIGN KEY (MaHS) REFERENCES HeSoTangCa(MaHS)
);
-- 10. Bảng TongHopChamCong
CREATE TABLE TongHopChamCong (
MaTH INT IDENTITY(1,1) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
NgayLamViec DATE NOT NULL,
SoGioLam DECIMAL(5, 2),
SoGioTangCa DECIMAL(5, 2),
TrangThai NVARCHAR(50),
late_minutes INT,
early_leave_minutes INT,
MaHS VARCHAR(5),
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
FOREIGN KEY (MaHS) REFERENCES HeSoTangCa(MaHS)
);
-- 11. Bảng KhenThuong (Thông tin chung về khen thưởng)
CREATE TABLE KhenThuong (
MaKhenThuong VARCHAR(5) PRIMARY KEY,
MoTa NVARCHAR(255),
SoTienThuong DECIMAL(18, 2)
);
-- 12. Bảng ChiTietKhenThuong (Chi tiết các đợt khen thưởng)
CREATE TABLE ChiTietKhenThuong (
STKT INT IDENTITY(1,1) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
NgayKhenThuong DATE,
MaKhenThuong VARCHAR(5) NOT NULL,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
FOREIGN KEY (MaKhenThuong) REFERENCES KhenThuong(MaKhenThuong)
);
-- 13. Bảng KyLuat (Thông tin chung về kỷ luật)
CREATE TABLE KyLuat (
MaKyLuat VARCHAR(5) PRIMARY KEY,
MoTa NVARCHAR(255),
SoTienPhat DECIMAL(18, 2)
);
-- 14. Bảng ChiTietKyLuat (Chi tiết các đợt kỷ luật)
CREATE TABLE ChiTietKyLuat (
STKL INT IDENTITY(1,1) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
NgayKyLuat DATE,
MaKyLuat VARCHAR(5) NOT NULL,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
FOREIGN KEY (MaKyLuat) REFERENCES KyLuat(MaKyLuat)
);
-- 15. Bảng PhuCap (Thông tin chung về phụ cấp)
CREATE TABLE PhuCap (
MaPhuCap VARCHAR(5) PRIMARY KEY,
MoTa NVARCHAR(255),
SoTienPhuCap DECIMAL(18, 2)
);
-- 16. Bảng ChiTietPhuCap (Chi tiết các đợt phụ cấp)
CREATE TABLE ChiTietPhuCap (
STPC INT IDENTITY(1,1) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
NgayNhan DATE,
MaPhuCap VARCHAR(5) NOT NULL,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
FOREIGN KEY (MaPhuCap) REFERENCES PhuCap(MaPhuCap)
);
-- 17. Bảng BangLuong
CREATE TABLE BangLuong (
MaLuong VARCHAR(5) PRIMARY KEY,
MaNV VARCHAR(5) NOT NULL,
KiLuong INT,
SoNgayLamViec DECIMAL(5, 2),
SoGioLamViec DECIMAL(5, 2),
SoGioTangCa DECIMAL(18, 2),
LuongCoBan DECIMAL(18, 2),
LuongTangCa DECIMAL(18, 2),
TongKyLuat DECIMAL(18, 2),
TongTienKhenThuong DECIMAL(18, 2),
PhuCapDacBiet DECIMAL(18, 2),
ThucLinh DECIMAL(18, 2),
late_days DECIMAL(5, 2),
early_leave_days DECIMAL(5, 2),
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
--18. Bảng loại phép
CREATE TABLE LoaiPhep (
    MaLoaiPhep VARCHAR(5) PRIMARY KEY, -- Khóa chính
    TenLoaiNghi NVARCHAR(50) NOT NULL, -- Tên loại nghỉ (VD: Phép năm, Nghỉ ốm)
    HeSoHuongLuong DECIMAL(3, 2) CHECK (HeSoHuongLuong BETWEEN 0 AND 1), -- VD: 1.0 (100%), 0.75 (75%)
    SoCapDuyet INT DEFAULT 2, -- Số cấp cần duyệt (mặc định là 2)
    MoTa NVARCHAR(255)
);
--19. Bảng Quỹ phép
CREATE TABLE QuyPhep (
    MaQuyPhep INT IDENTITY(1,1) PRIMARY KEY,
    MaNV VARCHAR(5) NOT NULL, -- Khóa ngoại nối với bảng NhanVien
    Nam INT NOT NULL, -- Năm quản lý (VD: 2026)
    TongPhepDuocNghi INT DEFAULT 12, -- Thường là 12 ngày/năm
    SoNgayDaNghi DECIMAL(4,1) DEFAULT 0, -- Cập nhật sau khi đơn được duyệt thành công
    -- Cột tính toán tự động: Số ngày còn lại = Tổng phép - Đã nghỉ
    SoNgayConLai AS (TongPhepDuocNghi - SoNgayDaNghi), 
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT UC_QuyPhep_NV_Nam UNIQUE (MaNV, Nam) -- Ràng buộc: Mỗi NV chỉ có 1 dòng quỹ phép mỗi năm
);
--20. Bảng Đơn nghỉ phép
CREATE TABLE DonNghiPhep (
    MaDon VARCHAR(10) PRIMARY KEY,
    MaNV VARCHAR(5) NOT NULL,
    MaLoaiPhep VARCHAR(5) NOT NULL,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    SoNgayNghi DECIMAL(4,1), -- Tổng số ngày nghỉ của đơn đó
    LyDo NVARCHAR(255),
    NgayTao DATETIME DEFAULT GETDATE(),
    -- Trạng thái: Chờ duyệt, Thành công (đã duyệt xong các cấp), Bị từ chối
    TrangThai NVARCHAR(20) CHECK (TrangThai IN (N'Chờ duyệt', N'Thành công', N'Bị từ chối')),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    FOREIGN KEY (MaLoaiPhep) REFERENCES LoaiPhep(MaLoaiPhep),
    CONSTRAINT CK_NgayNghi CHECK (NgayKetThuc >= NgayBatDau) -- Ràng buộc ngày kết thúc phải sau ngày bắt đầu
);
--21. Bảng chi tiết duyệt phép
CREATE TABLE ChiTietDuyetPhep (
    MaDuyet INT IDENTITY(1,1) PRIMARY KEY,
    MaDon VARCHAR(10) NOT NULL,
    MaNguoiDuyet VARCHAR(5) NOT NULL, -- Khóa ngoại nối với bảng NhanVien (người duyệt)
    CapDuyet INT, -- 1: Trưởng phòng, 2: Nhân sự/Giám đốc
    ThoiGianDuyet DATETIME DEFAULT GETDATE(),
    KetQua NVARCHAR(20) CHECK (KetQua IN (N'Approved', N'Rejected')),
    GhiChu NVARCHAR(255), -- Lý do duyệt hoặc từ chối
    FOREIGN KEY (MaDon) REFERENCES DonNghiPhep(MaDon),
    FOREIGN KEY (MaNguoiDuyet) REFERENCES NhanVien(MaNV)
);
-- Ràng buộc ngày kết thúc không được nhỏ hơn ngày bắt đầu
ALTER TABLE HopDong ADD CONSTRAINT CK_NgayHopDong CHECK (NgayKetThuc >= NgayBatDau);
ALTER TABLE DonNghiPhep ADD CONSTRAINT CK_NgayNghi CHECK (NgayKetThuc >= NgayBatDau);

-- Ràng buộc lương không được âm
ALTER TABLE HopDong ADD CONSTRAINT CK_LuongDuong CHECK (LuongCoBan >= 0 AND TroCap >= 0);
ALTER TABLE BangLuong ADD CONSTRAINT CK_ThucLinh CHECK (ThucLinh >= 0);
