IF DB_ID('QL_SIEUTHIMINI_TIEMTAPHOA') IS NULL
    CREATE DATABASE QL_SIEUTHIMINI_TIEMTAPHOA;
GO
USE QL_SIEUTHIMINI_TIEMTAPHOA;
GO


/* =======================
   TẠO CÁC BẢNG CHÍNH
   ======================= */
CREATE TABLE VAITRO (
    MAROLE NVARCHAR(10) PRIMARY KEY,
    MOTA NVARCHAR(50)
);

CREATE TABLE TAIKHOAN (
    USERNAME VARCHAR(20) PRIMARY KEY,
    PASSWORD VARCHAR(100) NOT NULL,
    MAROLE NVARCHAR(10) NOT NULL,
    EMAIL VARCHAR(50) UNIQUE NOT NULL,
    TRANGTHAI NVARCHAR(50),
    NGAYKHOA DATE,
    NGAYMOKHOA DATE,
    CONSTRAINT FK_TAIKHOAN_VAITRO FOREIGN KEY(MAROLE) REFERENCES VAITRO(MAROLE)
);
SELECT * FROM TAIKHOAN
create table OTP_LOG(
	ID INT IDENTITY PRIMARY KEY,
    USERNAME VARCHAR(20) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL,
	OTP_CODE VARCHAR(6)NOT NULL,
	CREATE_AT DATETIME NOT NULL DEFAULT GETDATE(),
	EXPIRY_AT DATETIME NOT NULL,
	CONSTRAINT FK_OTP_LOG_TAIKHOAN FOREIGN KEY(USERNAME) REFERENCES TAIKHOAN(USERNAME)
)

CREATE TABLE NGUOIDUNG (
    ID INT IDENTITY PRIMARY KEY,
    USERNAME VARCHAR(20) UNIQUE NOT NULL,
    HOTEN NVARCHAR(30) NOT NULL,
    NGAYSINH DATE,
    GioiTinh NVARCHAR(3) CHECK (GioiTinh IN ('Nam', N'Nữ')),
    DIACHI NVARCHAR(40),
    SDT VARCHAR(10) CHECK (LEN(SDT)=10 AND SDT LIKE '[0-9]%'),
    CHUCVU NVARCHAR(30),
    LUONG MONEY CHECK (LUONG >= 0),
    DIEMTICHLUY INT,
    CONSTRAINT FK_NGUOIDUNG_TAIKHOAN FOREIGN KEY(USERNAME) REFERENCES TAIKHOAN(USERNAME)
);


CREATE TABLE HDBAN (
    MAHD VARCHAR(10) PRIMARY KEY ,
    NGAYLAP DATE NOT NULL,
	NGUOILAP_ID INT NOT NULL,      
	NGUOIMUA_ID INT NOT NULL,      
	GHICHU NVARCHAR(200),
	FOREIGN KEY (NGUOILAP_ID) REFERENCES NGUOIDUNG(ID),
	FOREIGN KEY (NGUOIMUA_ID) REFERENCES NGUOIDUNG(ID)
);

CREATE TABLE NHACUNGCAP (
    MANCC VARCHAR(10) NOT NULL,
    TENNCC NVARCHAR(30),
    DIACHI NVARCHAR(40),
    SDT VARCHAR(10) CHECK (LEN(SDT) = 10 AND SDT LIKE '[0-9]%'),
    EMAIL VARCHAR(30),
    CONSTRAINT PK_NHACUNGCAP PRIMARY KEY(MANCC)
);
CREATE TABLE HDNHAP (
    MAHDNHAP VARCHAR(10) NOT NULL,
    NGAYLAP DATETIME NOT NULL,
    USERNAME VARCHAR(20),
    MANCC VARCHAR(10) NOT NULL,
    GHICHU NVARCHAR(225),
    CONSTRAINT PK_HDNHAP PRIMARY KEY(MAHDNHAP),
    CONSTRAINT FK_HDNHAP_NHACC FOREIGN KEY(MANCC) REFERENCES NHACUNGCAP(MANCC),
    CONSTRAINT FK_HDNHAP_NHANVIEN FOREIGN KEY(USERNAME) REFERENCES NGUOIDUNG(USERNAME)
);



CREATE TABLE LOAISANPHAM (
    MALOAI VARCHAR(10) NOT NULL,
	TENLOAI NVARCHAR(100),
	HSD_NGAY INT,
    CONSTRAINT PK_LOAISANPHAM PRIMARY KEY(MALOAI)
);

CREATE TABLE SANPHAM (
    MALOAI VARCHAR(10) NOT NULL,
    MASP VARCHAR(10) NOT NULL,
    TENSP NVARCHAR(100),
	HINH NVARCHAR (255),
    NSX DATE,
    DVT NVARCHAR(10),
    GIABAN MONEY,
    SOLUONG INT,
    MANCC VARCHAR(10) NOT NULL,
    BARCODE VARCHAR(64) NULL,
    GHICHU NVARCHAR(100),
    CONSTRAINT PK_MASP PRIMARY KEY(MASP),
    CONSTRAINT FK_MASP_LOAISANPHAM FOREIGN KEY(MALOAI) REFERENCES LOAISANPHAM(MALOAI),
    CONSTRAINT FK_MAS_NHACUNGCAP FOREIGN KEY(MANCC) REFERENCES NHACUNGCAP(MANCC)
);

CREATE TABLE CHITIETHDNHAP (
    MAHDNHAP VARCHAR(10) NOT NULL,
    MASP VARCHAR(10) NOT NULL,
    SOLUONGTN INT NOT NULL CHECK (SOLUONGTN >= 0),
    DONGIANHAP INT NOT NULL,
    THANHTIENN AS (SOLUONGTN * DONGIANHAP) PERSISTED,
    GHICHU NVARCHAR(225),
    CONSTRAINT PK_CHITIETHDNHAP PRIMARY KEY(MAHDNHAP, MASP),
    CONSTRAINT FK_CHITIETHDNHAP_SANPHAM FOREIGN KEY(MASP) REFERENCES SANPHAM(MASP),
    CONSTRAINT FK_CHITIETHDNHAP_HDNHAP FOREIGN KEY(MAHDNHAP) REFERENCES HDNHAP(MAHDNHAP)
);



CREATE TABLE CHITIETHDBAN (
    MAHD VARCHAR(10) NOT NULL,
    MASP VARCHAR(10) NOT NULL,
    SOLUONG INT,
    DONGIA MONEY CHECK (DONGIA >= 0),
    THANHTIEN AS (SOLUONG * DONGIA) PERSISTED,
    CONSTRAINT PK_CHITIETHDBAN PRIMARY KEY(MAHD, MASP),
    CONSTRAINT FK_CHITIETHDBAN FOREIGN KEY(MAHD) REFERENCES HDBAN(MAHD),
    CONSTRAINT FK_CHITIETHDBAN_SANPHAM FOREIGN KEY(MASP) REFERENCES SANPHAM(MASP)
);


CREATE TABLE CONGNO (
    MACONGNO VARCHAR(20) NOT NULL,
    MAHD_NHAP VARCHAR(10) NOT NULL,
    MANCC VARCHAR(10) NOT NULL,
    NGAYPHATSINH DATE NOT NULL DEFAULT GETDATE(),
    SOTIENPHAITRA MONEY NOT NULL,
    DATHANHTOAN MONEY NOT NULL DEFAULT 0 CHECK (DATHANHTOAN >= 0),
    CONLAI AS (SOTIENPHAITRA - DATHANHTOAN) PERSISTED,
    HANTRA DATE NULL,
    TRANGTHAI NVARCHAR(50) DEFAULT N'Chưa thanh toán',
    GHICHU NVARCHAR(500),
    CONSTRAINT PK_CONGNO PRIMARY KEY(MACONGNO),
    CONSTRAINT FK_CONGNO_NHACUNGCAP FOREIGN KEY(MANCC) REFERENCES NHACUNGCAP(MANCC),
    CONSTRAINT FK_CONGNO_HDNHAP FOREIGN KEY(MAHD_NHAP) REFERENCES HDNHAP(MAHDNHAP)
);

CREATE TABLE PHIEUTHANHTOAN (
    MAPTT VARCHAR(10),
    MACONGNO VARCHAR(20) NOT NULL,
    SOTIENTRA MONEY NOT NULL,
    NGAYTRA DATE NOT NULL DEFAULT GETDATE(),
    GHICHU NVARCHAR(100),
    CONSTRAINT PK_PHIEUTHANHTOAN PRIMARY KEY(MAPTT),
    CONSTRAINT FK_PHIEUTHANHTOAN_CONGNO FOREIGN KEY(MACONGNO) REFERENCES CONGNO(MACONGNO)
);

CREATE TABLE LICHLAM (
    MALICH INT IDENTITY(1,1) PRIMARY KEY,
    NGUOIDUNG_ID INT NOT NULL,          -- khóa ngoại trỏ về NGUOIDUNG(ID)
    NGAYLAM DATE NOT NULL,
    CALAM NVARCHAR(20),                 -- ví dụ: 'Sáng', 'Chiều', 'Tối'
    GIOVAO TIME,
    GIORA TIME,
    GHICHU NVARCHAR(100),
    CONSTRAINT FK_LICHLAM_NGUOIDUNG FOREIGN KEY (NGUOIDUNG_ID) REFERENCES NGUOIDUNG(ID)
);


	CREATE TABLE CHAMCONG (
    MACHAM INT IDENTITY PRIMARY KEY,
    MANV INT NOT NULL,
    NGAYLAM DATE NOT NULL,
    GIOVAO TIME,
    GIORA TIME,
    SOGIO FLOAT,
    TRANGTHAI NVARCHAR(20),
    LICHLAM_ID INT,
    FOREIGN KEY (MANV) REFERENCES NGUOIDUNG(ID),
    FOREIGN KEY (LICHLAM_ID) REFERENCES LICHLAM(MALICH)
);

   ---- TRIGGERS ----
--Lap hoa don
GO
CREATE TRIGGER trg_CheckRole_HDBAN
ON HDBAN
FOR INSERT, UPDATE
AS
BEGIN
    -- Check người lập phải là NV hoặc ADMIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN NGUOIDUNG nd ON i.NGUOILAP_ID = nd.ID
        JOIN TAIKHOAN tk ON nd.USERNAME = tk.USERNAME
        WHERE tk.MAROLE NOT IN ('NV', 'ADMIN')
    )
    BEGIN
        RAISERROR('Người lập phải là Nhân viên hoặc Admin!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Check người mua phải là KH
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN NGUOIDUNG nd ON i.NGUOIMUA_ID = nd.ID
        JOIN TAIKHOAN tk ON nd.USERNAME = tk.USERNAME
        WHERE tk.MAROLE <> 'KH'
    )
    BEGIN
        RAISERROR('Người mua phải là Khách hàng!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Nhập hàng
CREATE TRIGGER trg_Update_SoLuongNhap
ON CHITIETHDNHAP
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SP
    SET SP.SOLUONG = SP.SOLUONG + I.SOLUONGTN
    FROM SANPHAM SP
    JOIN INSERTED I ON SP.MASP = I.MASP;
END;
GO

-- Bán hàng
CREATE TRIGGER trg_Update_SoLuongBan
ON CHITIETHDBAN
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SP
    SET SP.SOLUONG = SP.SOLUONG - I.SOLUONG
    FROM SANPHAM SP
    JOIN INSERTED I ON SP.MASP = I.MASP;
END;
GO

--- TRIGGER CÔNG NỢ---

CREATE TRIGGER trg_UpdateCongNo_AfterPTT
ON PHIEUTHANHTOAN
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH upd AS (
        SELECT i.MACONGNO, SUM(i.SOTIENTRA) AS DaTraMoi
        FROM INSERTED i
        GROUP BY i.MACONGNO
    )
    UPDATE cn
    SET cn.DATHANHTOAN = cn.DATHANHTOAN + u.DaTraMoi,
        cn.TRANGTHAI = CASE 
            WHEN (cn.SOTIENPHAITRA - (cn.DATHANHTOAN + u.DaTraMoi)) <= 0 THEN N'Đã thanh toán'
            WHEN (cn.DATHANHTOAN + u.DaTraMoi) > 0 THEN N'Thanh toán một phần'
            ELSE N'Chưa thanh toán' END
    FROM CONGNO cn
    JOIN upd u ON u.MACONGNO = cn.MACONGNO;
END
GO


/* =======================
   VIEW
   ======================= */
-- Tồn kho
CREATE VIEW V_TONKHO AS 
SELECT 
    sp.MASP, sp.MALOAI, sp.TENSP, sp.NSX,
    CASE 
        WHEN sp.NSX IS NOT NULL AND l.HSD_NGAY IS NOT NULL
            THEN DATEADD(DAY, l.HSD_NGAY, sp.NSX)
        ELSE NULL
    END AS HSD,
    sp.DVT, sp.GIABAN, sp.MANCC,
    ISNULL(NHAP.SOLUONGNHAP, 0) AS SOLUONGNHAP,
    ISNULL(BAN.SOLUONGBAN, 0)   AS SOLUONGBAN,
    ISNULL(NHAP.SOLUONGNHAP, 0) - ISNULL(BAN.SOLUONGBAN, 0) AS SOLUONGTON
FROM SANPHAM sp
JOIN LOAISANPHAM l ON l.MALOAI = sp.MALOAI
LEFT JOIN (
    SELECT MASP, SUM(SOLUONGTN) AS SOLUONGNHAP 
    FROM CHITIETHDNHAP 
    GROUP BY MASP
) NHAP ON sp.MASP = NHAP.MASP
LEFT JOIN (
    SELECT MASP, SUM(SOLUONG) AS SOLUONGBAN 
    FROM CHITIETHDBAN 
    GROUP BY MASP
) BAN ON sp.MASP = BAN.MASP;
GO

-- Công nợ phải trả

CREATE VIEW V_CONGNO_PHAITRA AS
SELECT cn.MACONGNO, cn.MAHD_NHAP AS MAHD, cn.MANCC, ncc.TENNCC AS TENNHACUNGCAP,
       cn.NGAYPHATSINH, cn.SOTIENPHAITRA, cn.DATHANHTOAN, cn.CONLAI,
       cn.HANTRA, cn.TRANGTHAI, cn.GHICHU
FROM CONGNO cn
JOIN NHACUNGCAP ncc ON ncc.MANCC = cn.MANCC;


----Sản phẩm + Nhà Cung Cấp---
CREATE VIEW V_SANPHAM_NHACUNGCAP AS
SELECT SP.MASP,SP.TENSP,SP.SOLUONG,NCC.TENNCC
FROM SANPHAM SP
JOIN NHACUNGCAP NCC ON SP.MANCC = NCC.MANCC;

----Hạn Sử Dụng Sản phẩm---
CREATE OR ALTER VIEW V_SANPHAM_HSD
AS
WITH H AS (
    SELECT
        sp.MASP,
        sp.TENSP,
        sp.MALOAI,
        l.TENLOAI,
        sp.NSX,
        l.HSD_NGAY,
        CASE 
            WHEN sp.NSX IS NOT NULL AND l.HSD_NGAY IS NOT NULL
                THEN DATEADD(DAY, l.HSD_NGAY, sp.NSX)
            ELSE NULL
        END AS HSD
    FROM SANPHAM sp
    JOIN LOAISANPHAM l ON l.MALOAI = sp.MALOAI
)
SELECT
    MASP, TENSP, MALOAI, TENLOAI, NSX, HSD_NGAY, HSD,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), HSD) AS NgayConLai,
    CASE
        WHEN HSD IS NULL THEN N'Chưa đủ dữ liệu'
        WHEN HSD <  CAST(GETDATE() AS DATE) THEN N'Đã hết hạn'
        WHEN HSD <= DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN N'Sắp hết hạn (≤7 ngày)'
        ELSE N'Còn hạn'
    END AS TinhTrang
FROM H;
GO


-- Thống kê doanh thu
CREATE VIEW VIEW_ThongKeDoanhThu AS
SELECT CAST(h.NGAYLAP AS DATE) AS Ngay,
       ISNULL(SUM(ct.SOLUONG * ct.DONGIA), 0) AS DoanhThu,
       ISNULL((SELECT SUM(ctn.SOLUONGTN * ctn.DONGIANHAP)
               FROM HDNHAP n JOIN CHITIETHDNHAP ctn ON n.MAHDNHAP = ctn.MAHDNHAP
               WHERE CAST(n.NGAYLAP AS DATE) = CAST(h.NGAYLAP AS DATE)), 0) AS ChiPhi,
       ISNULL(SUM(ct.SOLUONG * ct.DONGIA), 0)
       - ISNULL((SELECT SUM(ctn.SOLUONGTN * ctn.DONGIANHAP)
                 FROM HDNHAP n JOIN CHITIETHDNHAP ctn ON n.MAHDNHAP = ctn.MAHDNHAP
                 WHERE CAST(n.NGAYLAP AS DATE) = CAST(h.NGAYLAP AS DATE)), 0) AS LoiNhuan
FROM HDBAN h
LEFT JOIN CHITIETHDBAN ct ON h.MAHD = ct.MAHD
GROUP BY CAST(h.NGAYLAP AS DATE);


--Insert du lieu---
INSERT INTO VAITRO (MAROLE, MOTA) VALUES
(N'ADMIN', N'Quản trị viên'),
(N'NV', N'Nhân viên'),
(N'KH', N'Khách hàng');

INSERT INTO TAIKHOAN (USERNAME, PASSWORD, MAROLE, EMAIL, TRANGTHAI, NGAYKHOA, NGAYMOKHOA) VALUES
-- 5 nhân viên
(N'user1',  N'123456', N'NV',    N'user1@company.com',  N'Hoạt động', NULL, NULL),
(N'user2',  N'123456', N'NV',    N'user2@company.com',  N'Hoạt động', NULL, NULL),
(N'user7',  N'123456', N'NV',    N'user7@company.com',  N'Hoạt động', NULL, NULL),
(N'user8',  N'123456', N'NV',    N'user8@gmail.com',    N'Hoạt động', NULL, NULL),
(N'user9',  N'123456', N'NV',    N'user9@company.com',  N'Khóa', GETDATE(), DATEADD(DAY,1,GETDATE())),

-- 3 khách hàng
(N'user3',  N'123456', N'KH',    N'user3@gmail.com',    N'Khóa', GETDATE(), DATEADD(DAY,1,GETDATE())),
(N'user5',  N'123456', N'KH',    N'user5@gmail.com',    N'Hoạt động', NULL, NULL),
(N'user6',  N'123456', N'KH',    N'user6@gmail.com',    N'Hoạt động', NULL, NULL),

-- 2 admin
(N'user4',  N'123456', N'ADMIN', N'admin4@company.com', N'Hoạt động', NULL, NULL),
(N'user10', N'123456', N'ADMIN', N'admin10@company.com',N'Khóa', GETDATE(), DATEADD(DAY,1,GETDATE()));


INSERT INTO OTP_LOG (USERNAME, EMAIL, OTP_CODE, CREATE_AT, EXPIRY_AT) VALUES
(N'user1',  'user1@company.com',  '482913', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user2',  'user2@company.com',  '753024', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user3',  'user3@gmail.com',    '105832', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user4',  'admin1@company.com', '698214', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user5',  'admin2@company.com', '340176', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user6',  'user6@gmail.com',    '912305', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user7',  'admin3@company.com', '826749', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user8',  'user8@gmail.com',    '217693', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user9',  'admin4@company.com', '564890', GETDATE(), DATEADD(MINUTE, 5, GETDATE())),
(N'user10', 'admin5@company.com', '479123', GETDATE(), DATEADD(MINUTE, 5, GETDATE()));




INSERT INTO NGUOIDUNG 
(USERNAME, HOTEN, NGAYSINH, GioiTinh, DIACHI, SDT, CHUCVU, LUONG, DIEMTICHLUY) VALUES
-- 5 nhân viên
(N'user1',  N'Nguyễn Văn A',        '1991-02-02', N'Nam', N'TP HCM',     N'0981111111', N'Nhân viên',      8500000, NULL),
(N'user2',  N'Trần Văn B',          '1992-03-03', N'Nam', N'Đà Lạt',     N'0932222222', N'Nhân viên',      9000000, NULL),
(N'user7',  N'Hoàng Thị Bảy',       '1997-08-08', N'Nữ',  N'TP HCM',     N'0933333333', N'Nhân viên',      9200000, NULL),
(N'user8',  N'Lê Thị Hoa',          '1998-09-09', N'Nữ',  N'TP HCM',     N'0914444444', N'Nhân viên',      9700000, NULL),
(N'user9',  N'Phạm Minh Anh',       '1999-10-10', N'Nữ',  N'Hà Nội',     N'0975555555', N'Nhân viên',      9300000, NULL),

-- 3 khách hàng
(N'user3',  N'Lâm Phước Thuận',     '1993-04-04', N'Nam', N'Vũng Tàu',   N'0926666666', NULL, NULL,        157),
(N'user5',  N'Nguyễn Văn Hùng',     '1995-06-06', N'Nam', N'TP HCM',     N'0987777777', NULL, NULL,        251),
(N'user6',  N'Lê Văn Sáu',          '1996-07-07', N'Nữ',  N'Bến Tre',    N'0948888888', NULL, NULL,        200),

-- 2 admin
(N'user4',  N'Nguyễn Khánh Duy',    '1994-05-05', N'Nam', N'Nha Trang',  N'0989999999', N'Quản trị viên',  16000000, NULL),
(N'user10', N'Nguyễn Thị Hai',      '1990-11-11', N'Nữ',  N'TP HCM',     N'0920000000', N'Quản trị viên',  17000000, NULL);

SELECT *
FROM NGUOIDUNG
WHERE CHUCVU = N'Nhân viên';

-- LICHLAM: 5 nhân viên, 7 ngày (1-7 Nov 2025), nhưng skip off-days đã nêu
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
-- user1 (ID=1) off 2025-11-04
(1,'2025-11-01',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-01',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-02',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-02',N'Tối','17:00','21:00',N'Ca tối'),
(1,'2025-11-03',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-03',N'Chiều','13:00','17:00',N'Ca chiều'),
-- skip 2025-11-04 (off)
(1,'2025-11-05',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-05',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-06',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-06',N'Tối','17:00','21:00',N'Ca tối'),
(1,'2025-11-07',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-07',N'Chiều','13:00','17:00',N'Ca chiều'),

-- user2 (ID=2) off 2025-11-05
(2,'2025-11-01',N'Sáng','07:30','11:30',N'Ca sáng'),
(2,'2025-11-01',N'Chiều','13:00','17:00',N'Ca chiều'),
(2,'2025-11-02',N'Sáng','07:30','11:30',N'Ca sáng'),
(2,'2025-11-02',N'Chiều','13:00','17:00',N'Ca chiều'),
(2,'2025-11-03',N'Chiều','13:00','17:00',N'Ca chiều'),
(2,'2025-11-03',N'Tối','17:00','21:00',N'Ca tối'),
(2,'2025-11-04',N'Sáng','07:30','11:30',N'Ca sáng'),
(2,'2025-11-04',N'Chiều','13:00','17:00',N'Ca chiều'),
-- skip 2025-11-05 (off)
(2,'2025-11-06',N'Sáng','07:30','11:30',N'Ca sáng'),
(2,'2025-11-06',N'Chiều','13:00','17:00',N'Ca chiều'),
(2,'2025-11-07',N'Chiều','13:00','17:00',N'Ca chiều'),
(2,'2025-11-07',N'Tối','17:00','21:00',N'Ca tối'),

-- user7 (ID=3) off 2025-11-03
(3,'2025-11-01',N'Sáng','07:30','11:30',N'Ca sáng'),
(3,'2025-11-01',N'Chiều','13:00','17:00',N'Ca chiều'),
(3,'2025-11-02',N'Sáng','07:30','11:30',N'Ca sáng'),
(3,'2025-11-02',N'Chiều','13:00','17:00',N'Ca chiều'),
-- skip 2025-11-03 (off)
(3,'2025-11-04',N'Chiều','13:00','17:00',N'Ca chiều'),
(3,'2025-11-04',N'Tối','17:00','21:00',N'Ca tối'),
(3,'2025-11-05',N'Sáng','07:30','11:30',N'Ca sáng'),
(3,'2025-11-05',N'Chiều','13:00','17:00',N'Ca chiều'),
(3,'2025-11-06',N'Sáng','07:30','11:30',N'Ca sáng'),
(3,'2025-11-06',N'Chiều','13:00','17:00',N'Ca chiều'),
(3,'2025-11-07',N'Sáng','07:30','11:30',N'Ca sáng'),
(3,'2025-11-07',N'Chiều','13:00','17:00',N'Ca chiều'),

-- user8 (ID=4) off 2025-11-06
(4,'2025-11-01',N'Chiều','13:00','17:00',N'Ca chiều'),
(4,'2025-11-01',N'Tối','17:00','21:00',N'Ca tối'),
(4,'2025-11-02',N'Sáng','07:30','11:30',N'Ca sáng'),
(4,'2025-11-02',N'Chiều','13:00','17:00',N'Ca chiều'),
(4,'2025-11-03',N'Sáng','07:30','11:30',N'Ca sáng'),
(4,'2025-11-03',N'Tối','17:00','21:00',N'Ca tối'),
(4,'2025-11-04',N'Chiều','13:00','17:00',N'Ca chiều'),
(4,'2025-11-04',N'Tối','17:00','21:00',N'Ca tối'),
(4,'2025-11-05',N'Sáng','07:30','11:30',N'Ca sáng'),
(4,'2025-11-05',N'Chiều','13:00','17:00',N'Ca chiều'),
-- skip 2025-11-06 (off)
(4,'2025-11-07',N'Chiều','13:00','17:00',N'Ca chiều'),
(4,'2025-11-07',N'Tối','17:00','21:00',N'Ca tối'),

-- user9 (ID=5) off 2025-11-02
(5,'2025-11-01',N'Sáng','07:30','11:30',N'Ca sáng'),
(5,'2025-11-01',N'Chiều','13:00','17:00',N'Ca chiều'),
-- skip 2025-11-02 (off)
(5,'2025-11-03',N'Chiều','13:00','17:00',N'Ca chiều'),
(5,'2025-11-03',N'Tối','17:00','21:00',N'Ca tối'),
(5,'2025-11-04',N'Sáng','07:30','11:30',N'Ca sáng'),
(5,'2025-11-04',N'Chiều','13:00','17:00',N'Ca chiều'),
(5,'2025-11-05',N'Chiều','13:00','17:00',N'Ca chiều'),
(5,'2025-11-05',N'Tối','17:00','21:00',N'Ca tối'),
(5,'2025-11-06',N'Sáng','07:30','11:30',N'Ca sáng'),
(5,'2025-11-06',N'Chiều','13:00','17:00',N'Ca chiều'),
(5,'2025-11-07',N'Sáng','07:30','11:30',N'Ca sáng'),
(5,'2025-11-07',N'Chiều','13:00','17:00',N'Ca chiều');


---2* LichLam
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(1,'2025-11-08',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-08',N'Chiều','13:00','17:00',N'Ca chiều'),

(1,'2025-11-09',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-09',N'Tối','17:00','21:00',N'Ca tối'),

(1,'2025-11-10',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-10',N'Tối','17:00','21:00',N'Ca tối'),

(1,'2025-11-11',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-11',N'Chiều','13:00','17:00',N'Ca chiều'),

-- 12 nghỉ

(1,'2025-11-13',N'Sáng','07:30','11:30',N'Ca sáng'),
(1,'2025-11-13',N'Tối','17:00','21:00',N'Ca tối'),

(1,'2025-11-14',N'Chiều','13:00','17:00',N'Ca chiều'),
(1,'2025-11-14',N'Tối','17:00','21:00',N'Ca tối');

INSERT INTO LICHLAM VALUES
(2,'2025-11-08',N'Sáng','07:30','11:30',N''),
(2,'2025-11-08',N'Chiều','13:00','17:00',N''),

(2,'2025-11-09',N'Sáng','07:30','11:30',N''),
(2,'2025-11-09',N'Tối','17:00','21:00',N''),

-- 10 nghỉ

(2,'2025-11-11',N'Chiều','13:00','17:00',N''),
(2,'2025-11-11',N'Tối','17:00','21:00',N''),

(2,'2025-11-12',N'Sáng','07:30','11:30',N''),
(2,'2025-11-12',N'Chiều','13:00','17:00',N''),

(2,'2025-11-13',N'Sáng','07:30','11:30',N''),
(2,'2025-11-13',N'Tối','17:00','21:00',N''),

(2,'2025-11-14',N'Chiều','13:00','17:00',N''),
(2,'2025-11-14',N'Tối','17:00','21:00',N'');

---------------
INSERT INTO LICHLAM VALUES
(3,'2025-11-08',N'Sáng','07:30','11:30',N''),
(3,'2025-11-08',N'Tối','17:00','21:00',N''),

(3,'2025-11-09',N'Chiều','13:00','17:00',N''),
(3,'2025-11-09',N'Tối','17:00','21:00',N''),

(3,'2025-11-10',N'Sáng','07:30','11:30',N''),
(3,'2025-11-10',N'Chiều','13:00','17:00',N''),

(3,'2025-11-11',N'Sáng','07:30','11:30',N''),
(3,'2025-11-11',N'Tối','17:00','21:00',N''),

(3,'2025-11-12',N'Chiều','13:00','17:00',N''),
(3,'2025-11-12',N'Tối','17:00','21:00',N''),

(3,'2025-11-13',N'Sáng','07:30','11:30',N''),
(3,'2025-11-13',N'Chiều','13:00','17:00',N'');


-- 14 nghỉ



---------

INSERT INTO LICHLAM VALUES
(4,'2025-11-08',N'Sáng','07:30','11:30',N''),
(4,'2025-11-08',N'Chiều','13:00','17:00',N''),

-- 9 nghỉ

(4,'2025-11-10',N'Chiều','13:00','17:00',N''),
(4,'2025-11-10',N'Tối','17:00','21:00',N''),

(4,'2025-11-11',N'Sáng','07:30','11:30',N''),
(4,'2025-11-11',N'Tối','17:00','21:00',N''),

(4,'2025-11-12',N'Chiều','13:00','17:00',N''),
(4,'2025-11-12',N'Tối','17:00','21:00',N''),

(4,'2025-11-13',N'Sáng','07:30','11:30',N''),
(4,'2025-11-13',N'Chiều','13:00','17:00',N''),

(4,'2025-11-14',N'Sáng','07:30','11:30',N''),
(4,'2025-11-14',N'Chiều','13:00','17:00',N'');

--------
INSERT INTO LICHLAM VALUES
-- 8 nghỉ

(5,'2025-11-09',N'Sáng','07:30','11:30',N''),
(5,'2025-11-09',N'Chiều','13:00','17:00',N''),

(5,'2025-11-10',N'Sáng','07:30','11:30',N''),
(5,'2025-11-10',N'Tối','17:00','21:00',N''),

(5,'2025-11-11',N'Chiều','13:00','17:00',N''),
(5,'2025-11-11',N'Tối','17:00','21:00',N''),

(5,'2025-11-12',N'Sáng','07:30','11:30',N''),
(5,'2025-11-12',N'Chiều','13:00','17:00',N''),

(5,'2025-11-13',N'Sáng','07:30','11:30',N''),
(5,'2025-11-13',N'Tối','17:00','21:00',N''),

(5,'2025-11-14',N'Chiều','13:00','17:00',N''),
(5,'2025-11-14',N'Tối','17:00','21:00',N'');


---3* LichLam
INSERT INTO LICHLAM VALUES
(1,'2025-11-15',N'Sáng','07:30','11:30',N''),(1,'2025-11-15',N'Chiều','13:00','17:00',N''),

(1,'2025-11-16',N'Sáng','07:30','11:30',N''),(1,'2025-11-16',N'Tối','17:00','21:00',N''),

-- 17 nghỉ

(1,'2025-11-18',N'Chiều','13:00','17:00',N''),(1,'2025-11-18',N'Tối','17:00','21:00',N''),

(1,'2025-11-19',N'Sáng','07:30','11:30',N''),(1,'2025-11-19',N'Chiều','13:00','17:00',N''),

(1,'2025-11-20',N'Sáng','07:30','11:30',N''),(1,'2025-11-20',N'Tối','17:00','21:00',N''),

(1,'2025-11-21',N'Chiều','13:00','17:00',N''),(1,'2025-11-21',N'Tối','17:00','21:00',N'');

INSERT INTO LICHLAM VALUES
(2,'2025-11-15',N'Sáng','07:30','11:30',N''),(2,'2025-11-15',N'Chiều','13:00','17:00',N''),

(2,'2025-11-16',N'Chiều','13:00','17:00',N''),(2,'2025-11-16',N'Tối','17:00','21:00',N''),

(2,'2025-11-17',N'Sáng','07:30','11:30',N''),(2,'2025-11-17',N'Tối','17:00','21:00',N''),

-- 19 nghỉ

(2,'2025-11-20',N'Sáng','07:30','11:30',N''),(2,'2025-11-20',N'Chiều','13:00','17:00',N''),

(2,'2025-11-21',N'Sáng','07:30','11:30',N''),(2,'2025-11-21',N'Chiều','13:00','17:00',N'');

INSERT INTO LICHLAM VALUES
(3,'2025-11-15',N'Sáng','07:30','11:30',N''),(3,'2025-11-15',N'Tối','17:00','21:00',N''),

(3,'2025-11-16',N'Chiều','13:00','17:00',N''),(3,'2025-11-16',N'Tối','17:00','21:00',N''),

(3,'2025-11-17',N'Sáng','07:30','11:30',N''),(3,'2025-11-17',N'Chiều','13:00','17:00',N''),

(3,'2025-11-18',N'Sáng','07:30','11:30',N''),(3,'2025-11-18',N'Tối','17:00','21:00',N''),

(3,'2025-11-19',N'Chiều','13:00','17:00',N''),(3,'2025-11-19',N'Tối','17:00','21:00',N''),

-- 20 nghỉ

(3,'2025-11-21',N'Sáng','07:30','11:30',N''),(3,'2025-11-21',N'Chiều','13:00','17:00',N'');


INSERT INTO LICHLAM VALUES
(4,'2025-11-15',N'Sáng','07:30','11:30',N''),(4,'2025-11-15',N'Chiều','13:00','17:00',N''),

(4,'2025-11-16',N'Sáng','07:30','11:30',N''),(4,'2025-11-16',N'Tối','17:00','21:00',N''),

(4,'2025-11-17',N'Chiều','13:00','17:00',N''),(4,'2025-11-17',N'Tối','17:00','21:00',N''),

-- 18 nghỉ

(4,'2025-11-19',N'Sáng','07:30','11:30',N''),(4,'2025-11-19',N'Chiều','13:00','17:00',N''),

(4,'2025-11-20',N'Sáng','07:30','11:30',N''),(4,'2025-11-20',N'Tối','17:00','21:00',N''),

(4,'2025-11-21',N'Chiều','13:00','17:00',N''),(4,'2025-11-21',N'Tối','17:00','21:00',N'');


INSERT INTO LICHLAM VALUES
(5,'2025-11-15',N'Sáng','07:30','11:30',N''),(5,'2025-11-15',N'Chiều','13:00','17:00',N''),

-- 16 nghỉ

(5,'2025-11-17',N'Sáng','07:30','11:30',N''),(5,'2025-11-17',N'Chiều','13:00','17:00',N''),

(5,'2025-11-18',N'Sáng','07:30','11:30',N''),(5,'2025-11-18',N'Tối','17:00','21:00',N''),

(5,'2025-11-19',N'Chiều','13:00','17:00',N''),(5,'2025-11-19',N'Tối','17:00','21:00',N''),

(5,'2025-11-20',N'Sáng','07:30','11:30',N''),(5,'2025-11-20',N'Chiều','13:00','17:00',N''),

(5,'2025-11-21',N'Tối','17:00','21:00',N''),(5,'2025-11-21',N'Chiều','13:00','17:00',N'');



---4* LichLam
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
-- user1 (ID=1)  -- nghỉ 2025-11-24
(1,'2025-11-22',N'Sáng','07:30','11:30',N''),
(1,'2025-11-22',N'Chiều','13:00','17:00',N''),
(1,'2025-11-23',N'Sáng','07:30','11:30',N''),
(1,'2025-11-23',N'Chiều','13:00','17:00',N''),
-- 2025-11-24 nghỉ
(1,'2025-11-25',N'Sáng','07:30','11:30',N''),
(1,'2025-11-25',N'Chiều','13:00','17:00',N''),
(1,'2025-11-26',N'Sáng','07:30','11:30',N''),
(1,'2025-11-26',N'Chiều','13:00','17:00',N''),
(1,'2025-11-27',N'Sáng','07:30','11:30',N''),
(1,'2025-11-27',N'Chiều','13:00','17:00',N''),
(1,'2025-11-28',N'Sáng','07:30','11:30',N''),
(1,'2025-11-28',N'Chiều','13:00','17:00',N''),

-- user2 (ID=2) -- nghỉ 2025-11-25 (user2 always on-time otherwise)
(2,'2025-11-22',N'Sáng','07:30','11:30',N''),
(2,'2025-11-22',N'Chiều','13:00','17:00',N''),
(2,'2025-11-23',N'Sáng','07:30','11:30',N''),
(2,'2025-11-23',N'Chiều','13:00','17:00',N''),
-- 2025-11-25 nghỉ
(2,'2025-11-24',N'Sáng','07:30','11:30',N''),
(2,'2025-11-24',N'Chiều','13:00','17:00',N''),
(2,'2025-11-26',N'Sáng','07:30','11:30',N''),
(2,'2025-11-26',N'Chiều','13:00','17:00',N''),
(2,'2025-11-27',N'Sáng','07:30','11:30',N''),
(2,'2025-11-27',N'Chiều','13:00','17:00',N''),
(2,'2025-11-28',N'Sáng','07:30','11:30',N''),
(2,'2025-11-28',N'Chiều','13:00','17:00',N''),

-- user7 (ID=3) -- nghỉ 2025-11-23
(3,'2025-11-22',N'Sáng','07:30','11:30',N''),
(3,'2025-11-22',N'Chiều','13:00','17:00',N''),
-- 2025-11-23 nghỉ
(3,'2025-11-24',N'Sáng','07:30','11:30',N''),
(3,'2025-11-24',N'Chiều','13:00','17:00',N''),
(3,'2025-11-25',N'Sáng','07:30','11:30',N''),
(3,'2025-11-25',N'Chiều','13:00','17:00',N''),
(3,'2025-11-26',N'Sáng','07:30','11:30',N''),
(3,'2025-11-26',N'Chiều','13:00','17:00',N''),
(3,'2025-11-27',N'Sáng','07:30','11:30',N''),
(3,'2025-11-27',N'Chiều','13:00','17:00',N''),
(3,'2025-11-28',N'Sáng','07:30','11:30',N''),
(3,'2025-11-28',N'Chiều','13:00','17:00',N''),

-- user8 (ID=4) -- nghỉ 2025-11-26
(4,'2025-11-22',N'Sáng','07:30','11:30',N''),
(4,'2025-11-22',N'Chiều','13:00','17:00',N''),
(4,'2025-11-23',N'Sáng','07:30','11:30',N''),
(4,'2025-11-23',N'Chiều','13:00','17:00',N''),
(4,'2025-11-24',N'Sáng','07:30','11:30',N''),
(4,'2025-11-24',N'Chiều','13:00','17:00',N''),
(4,'2025-11-25',N'Sáng','07:30','11:30',N''),
(4,'2025-11-25',N'Chiều','13:00','17:00',N''),
-- 2025-11-26 nghỉ
(4,'2025-11-27',N'Sáng','07:30','11:30',N''),
(4,'2025-11-27',N'Chiều','13:00','17:00',N''),
(4,'2025-11-28',N'Sáng','07:30','11:30',N''),
(4,'2025-11-28',N'Chiều','13:00','17:00',N''),

-- user9 (ID=5) -- nghỉ 2025-11-22
-- 2025-11-22 nghỉ
(5,'2025-11-23',N'Sáng','07:30','11:30',N''),
(5,'2025-11-23',N'Chiều','13:00','17:00',N''),
(5,'2025-11-24',N'Sáng','07:30','11:30',N''),
(5,'2025-11-24',N'Chiều','13:00','17:00',N''),
(5,'2025-11-25',N'Sáng','07:30','11:30',N''),
(5,'2025-11-25',N'Chiều','13:00','17:00',N''),
(5,'2025-11-26',N'Sáng','07:30','11:30',N''),
(5,'2025-11-26',N'Chiều','13:00','17:00',N''),
(5,'2025-11-27',N'Sáng','07:30','11:30',N''),
(5,'2025-11-27',N'Chiều','13:00','17:00',N''),
(5,'2025-11-28',N'Sáng','07:30','11:30',N''),
(5,'2025-11-28',N'Chiều','13:00','17:00',N'');
GO

--5*
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(2,'2025-11-29',N'Sáng','07:30','11:30',N''),
(2,'2025-11-29',N'Chiều','13:00','17:00',N'');


--6*
-- USER 1
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(1,'2025-11-29',N'Sáng','07:30','11:30',N''),
(1,'2025-11-29',N'Chiều','13:00','17:00',N''),
(1,'2025-11-30',N'Sáng','07:30','11:30',N''),
(1,'2025-11-30',N'Chiều','13:00','17:00',N'');

-- USER 2 (đã có ngày 29, chỉ thêm ngày 30)
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(2,'2025-11-30',N'Sáng','07:30','11:30',N''),
(2,'2025-11-30',N'Chiều','13:00','17:00',N'');

-- USER 3
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(3,'2025-11-29',N'Sáng','07:30','11:30',N''),
(3,'2025-11-29',N'Chiều','13:00','17:00',N''),
(3,'2025-11-30',N'Sáng','07:30','11:30',N''),
(3,'2025-11-30',N'Chiều','13:00','17:00',N'');

-- USER 4
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(4,'2025-11-29',N'Sáng','07:30','11:30',N''),
(4,'2025-11-29',N'Chiều','13:00','17:00',N''),
(4,'2025-11-30',N'Sáng','07:30','11:30',N''),
(4,'2025-11-30',N'Chiều','13:00','17:00',N'');

-- USER 5
INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU) VALUES
(5,'2025-11-29',N'Sáng','07:30','11:30',N''),
(5,'2025-11-29',N'Chiều','13:00','17:00',N''),
(5,'2025-11-30',N'Sáng','07:30','11:30',N''),
(5,'2025-11-30',N'Chiều','13:00','17:00',N'');


select * from LICHLAM

--- CHAMCONG
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- ===== 2025-11-01 =====
-- user1 (ID=1): Sáng (trễ 10'), Chiều (đúng)
(1,'2025-11-01','07:40','11:30',3.83,N'Muộn'),
(1,'2025-11-01','13:00','17:00',4.00,N'Đúng giờ'),

-- user2 (ID=2): both đúng
(2,'2025-11-01','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-01','13:00','17:00',4.00,N'Đúng giờ'),

-- user7 (ID=3): 01/11 both present (but morning vắng in this plan? we earlier set off for 3rd; here keep 1st present)
(3,'2025-11-01','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-01','13:05','17:00',3.92,N'Muộn'),

-- user8 (ID=4):
(4,'2025-11-01','13:00','17:00',4.00,N'Đúng giờ'),
(4,'2025-11-01','17:00','21:00',4.00,N'Đúng giờ'),

-- user9 (ID=5):
(5,'2025-11-01','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-01','13:00','17:00',4.00,N'Đúng giờ'),


-- ===== 2025-11-02 =====
-- user1 (ID=1): Chiều + Tối -> both present
(1,'2025-11-02','13:00','17:00',4.00,N'Đúng giờ'),
(1,'2025-11-02','17:00','21:00',4.00,N'Đúng giờ'),

-- user2 (ID=2):
(2,'2025-11-02','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-02','13:00','17:00',4.00,N'Đúng giờ'),

-- user7 (ID=3):
(3,'2025-11-02','07:35','11:30',3.92,N'Muộn'),
(3,'2025-11-02','13:00','17:00',4.00,N'Đúng giờ'),

-- user8 (ID=4):
(4,'2025-11-02','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-02','13:00','17:00',4.00,N'Đúng giờ'),

-- user9 (ID=5) -- off 2025-11-02 => NO CHAMCONG (no entries)


-- ===== 2025-11-03 =====
-- user1 (ID=1):
(1,'2025-11-03','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-03','13:00','17:00',4.00,N'Đúng giờ'),

-- user2 (ID=2):
(2,'2025-11-03','13:00','17:00',4.00,N'Đúng giờ'),
(2,'2025-11-03','17:00','21:00',4.00,N'Đúng giờ'),

-- user7 (ID=3) -- off 2025-11-03 => NO CHAMCONG

-- user8 (ID=4):
(4,'2025-11-03','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-03','17:00','21:00',4.00,N'Đúng giờ'),

-- user9 (ID=5):
(5,'2025-11-03','13:00','17:00',4.00,N'Đúng giờ'),
(5,'2025-11-03','17:00','21:00',4.00,N'Đúng giờ'),


-- ===== 2025-11-04 =====
-- user1 (ID=1) -- off 2025-11-04 => NO CHAMCONG

-- user2 (ID=2):
(2,'2025-11-04','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-04','13:00','17:00',4.00,N'Đúng giờ'),

-- user7 (ID=3):
(3,'2025-11-04','13:00','17:00',4.00,N'Đúng giờ'),
(3,'2025-11-04','17:00','21:00',4.00,N'Đúng giờ'),

-- user8 (ID=4):
(4,'2025-11-04','13:00','17:00',4.00,N'Đúng giờ'),
(4,'2025-11-04','17:00','21:00',4.00,N'Đúng giờ'),

-- user9 (ID=5):
(5,'2025-11-04','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-04','13:00','17:00',4.00,N'Đúng giờ'),


-- ===== 2025-11-05 =====
-- user1 (ID=1):
(1,'2025-11-05','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-05','13:00','17:00',4.00,N'Đúng giờ'),

-- user2 (ID=2) -- off 2025-11-05 => NO CHAMCONG

-- user7 (ID=3):
(3,'2025-11-05','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-05','13:00','17:00',4.00,N'Đúng giờ'),

-- user8 (ID=4):
(4,'2025-11-05','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-05','13:00','17:00',4.00,N'Đúng giờ'),

-- user9 (ID=5):
(5,'2025-11-05','13:00','17:00',4.00,N'Đúng giờ'),
(5,'2025-11-05','17:00','21:00',4.00,N'Đúng giờ'),


-- ===== 2025-11-06 =====
-- user1 (ID=1):
(1,'2025-11-06','13:00','17:00',4.00,N'Đúng giờ'),
(1,'2025-11-06','17:00','21:00',4.00,N'Đúng giờ'),

-- user2 (ID=2):
(2,'2025-11-06','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-06','13:00','17:00',4.00,N'Đúng giờ'),

-- user7 (ID=3):
(3,'2025-11-06','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-06','13:07','17:00',3.88,N'Muộn'),

-- user8 (ID=4) -- off 2025-11-06 => NO CHAMCONG

-- user9 (ID=5):
(5,'2025-11-06','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-06','13:00','17:00',4.00,N'Đúng giờ'),


-- ===== 2025-11-07 =====
-- user1 (ID=1):
(1,'2025-11-07','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-07','13:00','17:00',4.00,N'Đúng giờ'),

-- user2 (ID=2):
(2,'2025-11-07','13:00','17:00',4.00,N'Đúng giờ'),
(2,'2025-11-07','17:00','21:00',4.00,N'Đúng giờ'),

-- user7 (ID=3):
(3,'2025-11-07','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-07','13:00','17:00',4.00,N'Đúng giờ'),

-- user8 (ID=4):
(4,'2025-11-07','13:00','17:00',4.00,N'Đúng giờ'),
(4,'2025-11-07','17:00','21:00',4.00,N'Đúng giờ'),

-- user9 (ID=5):
(5,'2025-11-07','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-07','13:00','17:00',4.00,N'Đúng giờ');

----------2*
INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 2025-11-08 (Sáng trễ 6', Chiều đúng)
(1,'2025-11-08','07:36','11:30',3.90,N'Muộn'),
(1,'2025-11-08','13:00','17:00',4.00,N'Đúng giờ'),

-- 2025-11-09 (Chiều đúng, Tối vắng)
(1,'2025-11-09','13:00','17:00',4.00,N'Đúng giờ'),
(1,'2025-11-09',NULL,NULL,0,N'Vắng'),

-- 2025-11-10 (Sáng đúng, Tối trễ 9')
(1,'2025-11-10','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-10','17:09','21:00',3.85,N'Muộn'),

-- 2025-11-11 (Sáng đúng, Chiều trễ 14')
(1,'2025-11-11','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-11','13:14','17:00',3.77,N'Muộn'),

-- 2025-11-13 (Sáng vắng, Tối đúng)
(1,'2025-11-13',NULL,NULL,0,N'Vắng'),
(1,'2025-11-13','17:00','21:00',4.00,N'Đúng giờ'),

-- 2025-11-14 (Chiều đúng, Tối trễ 5')
(1,'2025-11-14','13:00','17:00',4.00,N'Đúng giờ'),
(1,'2025-11-14','17:05','21:00',3.92,N'Muộn');

INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
(2,'2025-11-08','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-08','13:00','17:00',4.00,N'Đúng giờ'),

(2,'2025-11-09','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-09','17:00','21:00',4.00,N'Đúng giờ'),

-- 10 nghỉ → không chấm công

(2,'2025-11-11','13:00','17:00',4.00,N'Đúng giờ'),
(2,'2025-11-11','17:00','21:00',4.00,N'Đúng giờ'),

(2,'2025-11-12','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-12','13:00','17:00',4.00,N'Đúng giờ'),

(2,'2025-11-13','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-13','17:00','21:00',4.00,N'Đúng giờ'),

(2,'2025-11-14','13:00','17:00',4.00,N'Đúng giờ'),
(2,'2025-11-14','17:00','21:00',4.00,N'Đúng giờ');

INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 8 (Sáng đúng, Tối trễ 7')
(3,'2025-11-08','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-08','17:07','21:00',3.88,N'Muộn'),

-- 9 (Chiều đúng, Tối đúng)
(3,'2025-11-09','13:00','17:00',4.00,N'Đúng giờ'),
(3,'2025-11-09','17:00','21:00',4.00,N'Đúng giờ'),

-- 10 (Sáng vắng, Chiều trễ 4')
(3,'2025-11-10',NULL,NULL,0,N'Vắng'),
(3,'2025-11-10','13:04','17:00',3.93,N'Muộn'),

-- 11 (Sáng đúng, Tối đúng)
(3,'2025-11-11','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-11','17:00','21:00',4.00,N'Đúng giờ'),

-- 12 (Chiều đúng, Tối trễ 11')
(3,'2025-11-12','13:00','17:00',4.00,N'Đúng giờ'),
(3,'2025-11-12','17:11','21:00',3.82,N'Muộn'),

-- 13 (Sáng đúng, Chiều vắng)
(3,'2025-11-13','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-13',NULL,NULL,0,N'Vắng');

INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 8 (Sáng đúng, Chiều đúng)
(4,'2025-11-08','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-08','13:00','17:00',4.00,N'Đúng giờ'),

-- 10 (Chiều trễ 12', Tối đúng)
(4,'2025-11-10','13:12','17:00',3.80,N'Muộn'),
(4,'2025-11-10','17:00','21:00',4.00,N'Đúng giờ'),

-- 11 (Sáng đúng, Tối vắng)
(4,'2025-11-11','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-11',NULL,NULL,0,N'Vắng'),

-- 12 (Chiều trễ 3', Tối đúng)
(4,'2025-11-12','13:03','17:00',3.95,N'Muộn'),
(4,'2025-11-12','17:00','21:00',4.00,N'Đúng giờ'),

-- 13 (Sáng đúng, Chiều đúng)
(4,'2025-11-13','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-13','13:00','17:00',4.00,N'Đúng giờ'),

-- 14 (Sáng vắng, Chiều đúng)
(4,'2025-11-14',NULL,NULL,0,N'Vắng'),
(4,'2025-11-14','13:00','17:00',4.00,N'Đúng giờ');

INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 9 (Sáng trễ 9', Chiều đúng)
(5,'2025-11-09','07:39','11:30',3.85,N'Muộn'),
(5,'2025-11-09','13:00','17:00',4.00,N'Đúng giờ'),

-- 10 (Sáng đúng, Tối trễ 6')
(5,'2025-11-10','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-10','17:06','21:00',3.90,N'Muộn'),

-- 11 (Chiều đúng, Tối đúng)
(5,'2025-11-11','13:00','17:00',4.00,N'Đúng giờ'),
(5,'2025-11-11','17:00','21:00',4.00,N'Đúng giờ'),

-- 12 (Sáng đúng, Chiều vắng)
(5,'2025-11-12','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-12',NULL,NULL,0,N'Vắng'),

-- 13 (Sáng đúng, Tối trễ 14')
(5,'2025-11-13','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-13','17:14','21:00',3.77,N'Muộn'),

-- 14 (Chiều đúng, Tối đúng)
(5,'2025-11-14','13:00','17:00',4.00,N'Đúng giờ'),
(5,'2025-11-14','17:00','21:00',4.00,N'Đúng giờ');




---3* ChamCong

INSERT INTO  CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 15
(1,'2025-11-15','07:35','11:30',3.92,N'Muộn'),
(1,'2025-11-15','13:00','17:00',4.00,N'Đúng giờ'),

-- 16
(1,'2025-11-16','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-16','17:10','21:00',3.83,N'Muộn'),

-- 17 nghỉ

-- 18
(1,'2025-11-18','13:05','17:00',3.92,N'Muộn'),
(1,'2025-11-18','17:00','21:00',4.00,N'Đúng giờ'),

-- 19
(1,'2025-11-19','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-19','13:10','17:00',3.83,N'Muộn'),

-- 20
(1,'2025-11-20','07:30','11:30',4.00,N'Đúng giờ'),
(1,'2025-11-20','17:00','21:00',4.00,N'Đúng giờ'),

-- 21
(1,'2025-11-21','13:00','17:00',4.00,N'Đúng giờ'),
(1,'2025-11-21','17:00','21:00',4.00,N'Đúng giờ');

INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 15
(2,'2025-11-15','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-15','13:00','17:00',4.00,N'Đúng giờ'),

-- 16
(2,'2025-11-16','13:00','17:00',4.00,N'Đúng giờ'),
(2,'2025-11-16','17:00','21:00',4.00,N'Đúng giờ'),

-- 17
(2,'2025-11-17','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-17','17:00','21:00',4.00,N'Đúng giờ'),

-- 19 nghỉ

-- 20
(2,'2025-11-20','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-20','13:00','17:00',4.00,N'Đúng giờ'),

-- 21
(2,'2025-11-21','07:30','11:30',4.00,N'Đúng giờ'),
(2,'2025-11-21','13:00','17:00',4.00,N'Đúng giờ');


INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 15
(3,'2025-11-15','07:40','11:30',3.83,N'Muộn'),
(3,'2025-11-15','17:00','21:00',4.00,N'Đúng giờ'),

-- 16
(3,'2025-11-16','13:10','17:00',3.83,N'Muộn'),
(3,'2025-11-16','17:00','21:00',4.00,N'Đúng giờ'),

-- 17
(3,'2025-11-17','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-17','13:07','17:00',3.88,N'Muộn'),

-- 18
(3,'2025-11-18','07:45','11:30',3.75,N'Muộn'),
(3,'2025-11-18','17:00','21:00',4.00,N'Đúng giờ'),

-- 19
(3,'2025-11-19','13:00','17:00',4.00,N'Đúng giờ'),
(3,'2025-11-19','17:00','21:00',4.00,N'Đúng giờ'),

-- 20 nghỉ

-- 21
(3,'2025-11-21','07:30','11:30',4.00,N'Đúng giờ'),
(3,'2025-11-21','13:00','17:00',4.00,N'Đúng giờ');


INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 15
(4,'2025-11-15','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-15','13:00','17:00',4.00,N'Đúng giờ'),

-- 16
(4,'2025-11-16','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-16','17:12','21:00',3.80,N'Muộn'),

-- 17
(4,'2025-11-17','13:00','17:00',4.00,N'Đúng giờ'),
(4,'2025-11-17','17:05','21:00',3.92,N'Muộn'),

-- 18 nghỉ

-- 19
(4,'2025-11-19','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-19','13:00','17:00',4.00,N'Đúng giờ'),

-- 20
(4,'2025-11-20','07:30','11:30',4.00,N'Đúng giờ'),
(4,'2025-11-20','17:00','21:00',4.00,N'Đúng giờ'),

-- 21
(4,'2025-11-21','13:00','17:00',4.00,N'Đúng giờ'),
(4,'2025-11-21','17:00','21:00',4.00,N'Đúng giờ');



INSERT INTO CHAMCONG(MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI) VALUES
-- 15
(5,'2025-11-15','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-15','13:00','17:00',4.00,N'Đúng giờ'),

-- 16 nghỉ

-- 17
(5,'2025-11-17','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-17','13:10','17:00',3.83,N'Muộn'),

-- 18
(5,'2025-11-18','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-18','17:00','21:00',4.00,N'Đúng giờ'),

-- 19
(5,'2025-11-19','13:00','17:00',4.00,N'Đúng giờ'),
(5,'2025-11-19','17:00','21:00',4.00,N'Đúng giờ'),

-- 20
(5,'2025-11-20','07:30','11:30',4.00,N'Đúng giờ'),
(5,'2025-11-20','13:00','17:00',4.00,N'Đúng giờ'),

-- 21
(5,'2025-11-21','17:00','21:00',4.00,N'Đúng giờ'),
(5,'2025-11-21','13:00','17:00',4.00,N'Đúng giờ');


---4* ChamCong
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-22','07:40','11:30',3.83,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-22' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-22','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-22' AND CALAM=N'Chiều';
-- 2025-11-23
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-23','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-23' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-23','13:05','17:00',3.92,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-23' AND CALAM=N'Chiều';
-- 2025-11-24 OFF -> no CHAMCONG
-- 2025-11-25
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-25','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-25' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-25','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-25' AND CALAM=N'Chiều';
-- 2025-11-26
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-26','07:42','11:30',3.80,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-26' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-26','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-26' AND CALAM=N'Chiều';
-- 2025-11-27 (chiều vắng)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-27','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-27' AND CALAM=N'Sáng';
-- chiều Vắng -> GIOVAO/GIORA NULL, SOGIO=0
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-27',NULL,NULL,0.00,N'Vắng', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-27' AND CALAM=N'Chiều';
-- 2025-11-28
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-28','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-28' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-28','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-28' AND CALAM=N'Chiều';

-- user2 (ID=2) -- nghỉ 25/11 -- ALWAYS ON-TIME
-- 2025-11-22
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-22','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-22' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-22','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-22' AND CALAM=N'Chiều';
-- 2025-11-23
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-23','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-23' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-23','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-23' AND CALAM=N'Chiều';
-- 2025-11-24
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-24','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-24' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-24','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-24' AND CALAM=N'Chiều';
-- 2025-11-25 OFF -> no CHAMCONG
-- 2025-11-26
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-26','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-26' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-26','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-26' AND CALAM=N'Chiều';
-- 2025-11-27
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-27','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-27' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-27','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-27' AND CALAM=N'Chiều';
-- 2025-11-28
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-28','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-28' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-28','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-28' AND CALAM=N'Chiều';

-- user7 (ID=3) -- nghỉ 23/11
-- 2025-11-22
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-22','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-22' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-22','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-22' AND CALAM=N'Chiều';
-- 2025-11-23 OFF
-- 2025-11-24 (both muộn a bit)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-24','07:38','11:30',3.87,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-24' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-24','13:10','17:00',3.83,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-24' AND CALAM=N'Chiều';
-- 2025-11-25
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-25','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-25' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-25','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-25' AND CALAM=N'Chiều';
-- 2025-11-26
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-26','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-26' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-26','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-26' AND CALAM=N'Chiều';
-- 2025-11-27 (sáng vắng)
-- Sáng Vắng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-27',NULL,NULL,0.00,N'Vắng', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-27' AND CALAM=N'Sáng';
-- Chiều đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-27','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-27' AND CALAM=N'Chiều';
-- 2025-11-28 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-28','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-28' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-28','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-28' AND CALAM=N'Chiều';

-- user8 (ID=4) -- nghỉ 26/11
-- 2025-11-22 (sáng đúng, chiều muộn)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-22','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-22' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-22','13:07','17:00',3.88,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-22' AND CALAM=N'Chiều';
-- 2025-11-23 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-23','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-23' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-23','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-23' AND CALAM=N'Chiều';
-- 2025-11-24 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-24','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-24' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-24','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-24' AND CALAM=N'Chiều';
-- 2025-11-25 (sáng muộn 15min -> still Muộn), chiều đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-25','07:45','11:30',3.75,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-25' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-25','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-25' AND CALAM=N'Chiều';
-- 2025-11-26 OFF
-- 2025-11-27 (chiều muộn)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-27','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-27' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-27','13:05','17:00',3.92,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-27' AND CALAM=N'Chiều';
-- 2025-11-28 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-28','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-28' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-28','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-28' AND CALAM=N'Chiều';

-- user9 (ID=5) -- nghỉ 22/11
-- 2025-11-22 OFF
-- 2025-11-23 (chiều muộn 12min)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-23','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-23' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-23','13:12','17:00',3.80,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-23' AND CALAM=N'Chiều';
-- 2025-11-24 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-24','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-24' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-24','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-24' AND CALAM=N'Chiều';
-- 2025-11-25 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-25','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-25' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-25','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-25' AND CALAM=N'Chiều';
-- 2025-11-26 (both muộn)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-26','07:40','11:30',3.83,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-26' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-26','13:08','17:00',3.87,N'Muộn', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-26' AND CALAM=N'Chiều';
-- 2025-11-27 both đúng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-27','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-27' AND CALAM=N'Sáng';
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-27','13:00','17:00',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-27' AND CALAM=N'Chiều';
-- 2025-11-28 (chiều vắng)
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-28','07:30','11:30',4.00,N'Đúng giờ', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-28' AND CALAM=N'Sáng';
-- chiều Vắng
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-28',NULL,NULL,0.00,N'Vắng', MALICH FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-28' AND CALAM=N'Chiều';
GO

--5*
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-29','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM 
WHERE NGUOIDUNG_ID = 2 AND NGAYLAM = '2025-11-29' AND CALAM = N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-29','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM 
WHERE NGUOIDUNG_ID = 2 AND NGAYLAM = '2025-11-29' AND CALAM = N'Chiều';




select * from CHAMCONG
select * from LICHLAM

--6*
-- 29/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-29','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-29' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-29','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-29' AND CALAM=N'Chiều';

-- 30/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-30','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-30' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 1,'2025-11-30','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=1 AND NGAYLAM='2025-11-30' AND CALAM=N'Chiều';

-- 30/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-30','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-30' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-30','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-30' AND CALAM=N'Chiều';


INSERT INTO LICHLAM (NGUOIDUNG_ID, NGAYLAM, CALAM, GIOVAO, GIORA, GHICHU)
VALUES
(2, '2025-11-10', N'Sáng',  '07:30', '11:30', N''),
(2, '2025-11-10', N'Chiều', '13:00', '17:00', N'');

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-10','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-10' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 2,'2025-11-10','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=2 AND NGAYLAM='2025-11-10' AND CALAM=N'Chiều';
----

-- 29/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-29','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-29' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-29','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-29' AND CALAM=N'Chiều';

-- 30/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-30','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-30' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 3,'2025-11-30','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=3 AND NGAYLAM='2025-11-30' AND CALAM=N'Chiều';


-------
-- 29/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-29','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-29' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-29','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-29' AND CALAM=N'Chiều';

-- 30/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-30','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-30' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 4,'2025-11-30','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=4 AND NGAYLAM='2025-11-30' AND CALAM=N'Chiều';

--------------
-- 29/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-29','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-29' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-29','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-29' AND CALAM=N'Chiều';

-- 30/11
INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-30','07:30','11:30',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-30' AND CALAM=N'Sáng';

INSERT INTO CHAMCONG (MANV, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI, LICHLAM_ID)
SELECT 5,'2025-11-30','13:00','17:00',4.00,N'Đúng giờ', MALICH 
FROM LICHLAM WHERE NGUOIDUNG_ID=5 AND NGAYLAM='2025-11-30' AND CALAM=N'Chiều';





UPDATE C
SET C.LICHLAM_ID = L.MALICH
FROM CHAMCONG C
JOIN LICHLAM L 
    ON C.MANV = L.NGUOIDUNG_ID
   AND C.NGAYLAM = L.NGAYLAM
   AND C.GIOVAO >= L.GIOVAO
   AND C.GIOVAO < L.GIORA;

SELECT * FROM CHAMCONG


-- Tắt FK
--ALTER TABLE CHAMCONG NOCHECK CONSTRAINT ALL;
--ALTER TABLE LICHLAM NOCHECK CONSTRAINT ALL;

-- Xóa sạch dữ liệu
--TRUNCATE TABLE CHAMCONG;
--TRUNCATE TABLE LICHLAM;
--DELETE FROM LICHLAM;
-- Bật FK lại
--ALTER TABLE CHAMCONG CHECK CONSTRAINT ALL;
--ALTER TABLE LICHLAM CHECK CONSTRAINT ALL;




INSERT INTO NHACUNGCAP (MANCC, TENNCC, DIACHI, SDT, EMAIL) VALUES
(N'NCC01', N'Nhà Cung Cấp 1', N'Địa chỉ NCC1', N'0951145299', N'ncc1@gmail.com'),
(N'NCC02', N'Nhà Cung Cấp 2', N'Địa chỉ NCC2', N'0935623453', N'ncc2@gmail.com'),
(N'NCC03', N'Nhà Cung Cấp 3', N'Địa chỉ NCC3', N'0933273910', N'ncc3@gmail.com'),
(N'NCC04', N'Nhà Cung Cấp 4', N'Địa chỉ NCC4', N'0990583291', N'ncc4@gmail.com'),
(N'NCC05', N'Nhà Cung Cấp 5', N'Địa chỉ NCC5', N'0910190062', N'ncc5@gmail.com'),
(N'NCC06', N'Nhà Cung Cấp 6', N'Địa chỉ NCC6', N'0982583848', N'ncc6@gmail.com'),
(N'NCC07', N'Nhà Cung Cấp 7', N'Địa chỉ NCC7', N'0965911808', N'ncc7@gmail.com'),
(N'NCC08', N'Nhà Cung Cấp 8', N'Địa chỉ NCC8', N'0985236047', N'ncc8@gmail.com'),
(N'NCC09', N'Nhà Cung Cấp 9', N'Địa chỉ NCC9', N'0969491257', N'ncc9@gmail.com'),
(N'NCC10', N'Nhà Cung Cấp 10', N'Địa chỉ NCC10', N'0982554568', N'ncc10@gmail.com');

INSERT INTO LOAISANPHAM (MALOAI, TENLOAI, HSD_NGAY) VALUES
('LSP1' , N'Sữa & chế phẩm sữa'            , 180),
('LSP2' , N'Sữa chua & đồ uống từ sữa'     , 120),
('LSP3' , N'Thực phẩm khô / mì / gạo'      , 360),
('LSP4' , N'Đồ uống đóng chai/lon'         , 365),
('LSP5' , N'Bánh kẹo & snack'              , 360),
('LSP6' , N'Hóa phẩm rửa chén - vệ sinh'   , 720),
('LSP7' , N'Giặt tẩy / xả vải'             , 720),
('LSP8' , N'Thực phẩm đông lạnh'           , 365),
('LSP9' , N'Rau củ quả tươi'               ,   7),
('LSP10', N'Thịt/cá tươi sống'             ,   5);



INSERT INTO SANPHAM (MALOAI, MASP, TENSP, HINH, NSX, DVT, GIABAN, SOLUONG, MANCC, BARCODE, GHICHU) VALUES
('LSP1' , 'SP001', N'Sữa tươi 1L',                 N'Sua1L.png',       '2025-03-10', N'Hộp', 28000, 100, 'NCC01', '8931234567890', N'Giữ lạnh 2–6°C; bán theo hộp/lốc'),
('LSP2' , 'SP002', N'Sữa chua uống 180ml',         N'SuaChuaUong.png',  '2025-04-05', N'Lốc',  6000, 200, 'NCC01', '8931234567891', N'Uống lạnh ngon hơn; combo 6 chai'),
('LSP3' , 'SP003', N'Mì Hảo Hảo tôm chua cay',     N'HaoHao.png',       '2025-02-20', N'Thùng',105000,  50, 'NCC02', '8931234567892', N'Thùng 30 gói; có bán lẻ từng gói'),
('LSP4' , 'SP004', N'Pepsi lon 330ml',             N'Pepsi.png',        '2025-09-15', N'Lon', 10000,  80, 'NCC03', '8931234567893', N'Trưng bày kệ giữa; chương trình 6+1'),
('LSP4' , 'SP005', N'7Up lon 330ml',               N'7Up.png',          '2025-09-16', N'Lon', 10000,  70, 'NCC03', '8931234567894', N'Giá tốt theo thùng 24 lon'),
('LSP5' , 'SP006', N'Chocopie hộp 12 cái',         N'Chocopie.png',     '2025-08-20', N'Hộp', 52000,  60, 'NCC04', '8931234567895', N'Hàng phổ biến; đặt kệ gần quầy bánh'),
('LSP5' , 'SP007', N'Snack khoai tây 90g',         N'SnackKhoai.png',   '2025-09-05', N'Gói', 18000,  90, 'NCC04', '8931234567896', N'Vị truyền thống; upsell combo nước'),
('LSP6' , 'SP008', N'Nước rửa chén Sunlight 750ml',N'Sunlight.png',     '2025-06-01', N'Chai', 38000, 120, 'NCC05', '8931234567897', N'Hương chanh; treo tag khuyến mãi'),
('LSP7' , 'SP009', N'Bột giặt OMO 3kg',            N'Omo.png',          '2025-05-10', N'Túi',195000, 110, 'NCC05', '8931234567898', N'Gói lớn tiết kiệm; vị trí kệ thấp'),
('LSP8' , 'SP010', N'Xúc xích đông lạnh 500g',     N'XucXich.png',      '2025-09-28', N'Gói', 65000,  80, 'NCC05', '8931234567899', N'Bảo quản -18°C; combo với tương ớt'),
('LSP9' , 'SP011', N'Rau xà lách 300g',            N'XaLach.png',       '2025-10-03', N'Bó' , 12000, 100, 'NCC06', '8931234567900', N'Hàng tươi trong ngày; phun sương nhẹ'),
('LSP10', 'SP012', N'Thịt heo xay 500g',           N'ThitHeoXay.png',   '2025-10-04', N'Khay', 85000,  90, 'NCC06', '8931234567901', N'Khối lượng chuẩn; đóng khay hút chân không'),
('LSP1' , 'SP013', N'Sữa tươi 180ml (lốc 4)',     N'Sua180.png',       '2025-09-10', N'Lốc', 26000,  60, 'NCC01', '8931234567902', N'Phù hợp trẻ em; chương trình tích điểm'),
('LSP3' , 'SP014', N'Mì Đệ Nhất bò hầm',           N'DeNhat.png',       '2025-07-30', N'Gói', 12000,  70, 'NCC02', '8931234567903', N'Vị bò hầm; đặt gần khu mì Hảo Hảo'),
('LSP4' , 'SP015', N'Aquafina 500ml',              N'Aquafina.png',     '2025-09-20', N'Chai', 7000, 200, 'NCC03', '8931234567904', N'Nước chai 500ml; đặt gần quầy thu ngân'),
('LSP4' , 'SP016', N'Trà xanh C2 455ml',          N'C2.png',            '2025-08-15', N'Chai',  9000, 150, 'NCC03', '8931234567905', N'Hàng nước giải khát bán chạy'),
('LSP5' , 'SP017', N'Kẹo bạc hà Halls 27g',       N'Halls.png',         '2025-06-20', N'Gói',  11000, 120, 'NCC04', '8931234567906', N'Đặt tại quầy tính tiền'),
('LSP8' , 'SP018', N'Khoai tây chiên đông lạnh',  N'FrozenFries.png',   '2025-09-01', N'Gói',  52000,  60, 'NCC05', '8931234567907', N'Chiên/nướng đều ngon; -18°C'),
('LSP9' , 'SP019', N'Cà chua 500g',               N'Tomato.png',        '2025-10-01', N'Khay', 18000,  80, 'NCC06', '8931234567908', N'Nông sản trong ngày'),
('LSP5' , 'SP020', N'Bánh quy Cosy 300g',         N'Cosy.png',          '2025-07-25', N'Hộp',  39000, 100, 'NCC04', '8931234567909', N'Bánh giòn; trưng bày kệ giữa'),
('LSP1' , 'SP021', N'Sữa đặc 380g',               N'SuaDac.png',        '2025-05-12', N'Lon',  23000, 120, 'NCC01', '8931234567910', N'Pha cà phê/bánh flan'),
('LSP1' , 'SP022', N'Phô mai Con Bò Cười 8 miếng',N'Phomai.png',        '2025-06-05', N'Hộp',  32000,  90, 'NCC01', '8931234567911', N'Bảo quản mát; hàng cho bé'),
('LSP2' , 'SP023', N'Sữa chua ăn 100g (lốc 4)',   N'SuaChuaAn.png',     '2025-05-18', N'Lốc',  26000, 110, 'NCC01', '8931234567912', N'Lốc 4 hũ; cần giữ lạnh'),
('LSP3' , 'SP024', N'Gạo ST25 5kg',               N'GaoST25.png',       '2025-04-01', N'Túi', 150000,  40, 'NCC02', '8931234567913', N'Gạo thơm; bày ở kệ thấp'),
('LSP4' , 'SP025', N'Sting đỏ 330ml',             N'Sting.png',         '2025-08-30', N'Lon',  10000, 160, 'NCC03', '8931234567914', N'Nước tăng lực; theo thùng 24 lon'),
('LSP5' , 'SP026', N'Kẹo dẻo Haribo 80g',         N'Haribo.png',        '2025-06-15', N'Gói',  22000,  70, 'NCC04', '8931234567915', N'Hàng nhập; trưng bày mắt lưới'),
('LSP6' , 'SP027', N'Nước lau sàn 1L',            N'LauSan.png',        '2025-06-10', N'Chai', 42000,  90, 'NCC05', '8931234567916', N'Hương hoa; combo với nước rửa chén'),
('LSP7' , 'SP028', N'Nước xả Downy 1.5L',         N'Downy.png',         '2025-05-22', N'Chai',115000,  75, 'NCC05', '8931234567917', N'Lưu hương lâu; kệ giặt tẩy'),
('LSP8' , 'SP029', N'Cá viên đông lạnh 500g',     N'CaVien.png',        '2025-08-12', N'Gói',  59000,  65, 'NCC05', '8931234567918', N'Bảo quản -18°C; bán kèm tương ớt'),
('LSP4' , 'SP030', N'Nước suối Lavie 1.5L',       N'Lavie1_5L.png',     '2025-09-02', N'Chai', 12000, 180, 'NCC03', '8931234567919', N'Nước chai dung tích lớn');


-- BẢNG HÓA ĐƠN BÁN
INSERT INTO HDBAN (MAHD, NGAYLAP, NGUOILAP_ID, NGUOIMUA_ID, GHICHU) VALUES
(N'HDB1', '2024-07-11', 3, 6, N'Ghi chú hóa đơn bán 1'),
(N'HDB2', '2024-04-03', 1, 9, N'Ghi chú hóa đơn bán 2'),
(N'HDB3', '2024-12-28', 1, 10, N'Ghi chú hóa đơn bán 3'),
(N'HDB4', '2024-04-21', 1, 9, N'Ghi chú hóa đơn bán 4'),
(N'HDB5', '2024-02-14', 2, 6, N'Ghi chú hóa đơn bán 5'),
(N'HDB6', '2024-10-19', 2, 9, N'Ghi chú hóa đơn bán 6'),
(N'HDB7', '2024-10-17', 4, 7, N'Ghi chú hóa đơn bán 7'),
(N'HDB8', '2024-05-10', 1, 9, N'Ghi chú hóa đơn bán 8'),
(N'HDB9', '2024-09-08', 3, 9, N'Ghi chú hóa đơn bán 9'),
(N'HDB10', '2024-04-27', 2, 7, N'Ghi chú hóa đơn bán 10');

DISABLE TRIGGER trg_CheckRole_HDBAN ON HDBAN;
ENABLE TRIGGER trg_CheckRole_HDBAN ON HDBAN;

SELECT * FROM HDBAN

-- BẢNG HÓA ĐƠN NHẬP
INSERT INTO HDNHAP (MAHDNHAP, NGAYLAP, USERNAME, MANCC, GHICHU) VALUES
(N'HDN1', '2024-05-19', N'user4', N'NCC04', N'Ghi chú nhập hàng 1'),
(N'HDN2', '2024-11-13', N'user4', N'NCC09', N'Ghi chú nhập hàng 2'),
(N'HDN3', '2024-10-06', N'user5', N'NCC09', N'Ghi chú nhập hàng 3'),
(N'HDN4', '2024-12-15', N'user3', N'NCC03', N'Ghi chú nhập hàng 4'),
(N'HDN5', '2024-01-05', N'user3', N'NCC03', N'Ghi chú nhập hàng 5'),
(N'HDN6', '2024-09-20', N'user2', N'NCC04', N'Ghi chú nhập hàng 6'),
(N'HDN7', '2024-07-25', N'user5', N'NCC04', N'Ghi chú nhập hàng 7'),
(N'HDN8', '2024-06-01', N'user5', N'NCC03', N'Ghi chú nhập hàng 8'),
(N'HDN9', '2024-06-07', N'user1', N'NCC06', N'Ghi chú nhập hàng 9'),
(N'HDN10', '2024-03-19', N'user5', N'NCC01', N'Ghi chú nhập hàng 10');

-- CHI TIẾT HÓA ĐƠN NHẬP
INSERT INTO CHITIETHDNHAP (MAHDNHAP, MASP, SOLUONGTN, DONGIANHAP, GHICHU) VALUES
(N'HDN2', N'SP001', 35, 22654, N'Ghi chú nhập 1'),
(N'HDN5', N'SP004', 12, 10041, N'Ghi chú nhập 2'),
(N'HDN5', N'SP006', 12, 12705, N'Ghi chú nhập 3'),
(N'HDN3', N'SP009', 23, 41532, N'Ghi chú nhập 4'),
(N'HDN5', N'SP001', 50, 18522, N'Ghi chú nhập 5'),
(N'HDN4', N'SP001', 45, 47493, N'Ghi chú nhập 6'),
(N'HDN6', N'SP010', 45, 13143, N'Ghi chú nhập 7'),
(N'HDN2', N'SP006', 44, 18681, N'Ghi chú nhập 8'),
(N'HDN8', N'SP006', 39, 29930, N'Ghi chú nhập 9'),
(N'HDN6', N'SP007', 11, 49530, N'Ghi chú nhập 10');

-- CHI TIẾT HÓA ĐƠN BÁN
INSERT INTO CHITIETHDBAN (MAHD, MASP, SOLUONG, DONGIA) VALUES
(N'HDB6', N'SP003', 5, 57469),
(N'HDB4', N'SP010', 8, 21901),
(N'HDB2', N'SP010', 5, 56351),
(N'HDB8', N'SP001', 4, 26535),
(N'HDB4', N'SP005', 9, 26869),
(N'HDB1', N'SP006', 5, 36825),
(N'HDB8', N'SP007', 3, 23958),
(N'HDB6', N'SP008', 6, 54643),
(N'HDB3', N'SP010', 2, 98267),
(N'HDB7', N'SP004', 1, 79058);

-- BẢNG CÔNG NỢ
INSERT INTO CONGNO (MACONGNO, MAHD_NHAP, MANCC, NGAYPHATSINH, SOTIENPHAITRA, DATHANHTOAN, HANTRA, TRANGTHAI, GHICHU) VALUES
(N'CN1', N'HDN1', N'NCC04', '2024-01-22', 2107308, 2135304, '2025-01-04', N'Đã thanh toán', N'Ghi chú công nợ 1'),
(N'CN2', N'HDN2', N'NCC05', '2024-04-21', 3569097, 2569207, '2025-06-21', N'Chưa thanh toán', N'Ghi chú công nợ 2'),
(N'CN3', N'HDN3', N'NCC06', '2024-05-26', 4852467, 2460877, '2025-04-21', N'Thanh toán một phần', N'Ghi chú công nợ 3'),
(N'CN4', N'HDN4', N'NCC08', '2024-11-16', 1755931, 1856189, '2025-03-24', N'Chưa thanh toán', N'Ghi chú công nợ 4'),
(N'CN5', N'HDN5', N'NCC05', '2024-09-04', 1774405, 67014, '2025-02-09', N'Chưa thanh toán', N'Ghi chú công nợ 5'),
(N'CN6', N'HDN6', N'NCC03', '2024-02-14', 543155, 1527038, '2025-04-28', N'Thanh toán một phần', N'Ghi chú công nợ 6'),
(N'CN7', N'HDN7', N'NCC07', '2024-12-11', 2574506, 1214550, '2025-05-27', N'Chưa thanh toán', N'Ghi chú công nợ 7'),
(N'CN8', N'HDN8', N'NCC05', '2024-11-14', 1550727, 2794547, '2025-03-15', N'Chưa thanh toán', N'Ghi chú công nợ 8'),
(N'CN9', N'HDN9', N'NCC08', '2024-08-21', 689695, 524508, '2025-05-27', N'Thanh toán một phần', N'Ghi chú công nợ 9'),
(N'CN10', N'HDN10', N'NCC01', '2024-01-02', 968710, 804363, '2025-04-27', N'Thanh toán một phần', N'Ghi chú công nợ 10');

-- BẢNG PHIẾU THANH TOÁN
INSERT INTO PHIEUTHANHTOAN (MAPTT, MACONGNO, SOTIENTRA, NGAYTRA, GHICHU) VALUES
(N'PTT1', N'CN9', 1667598, '2025-07-10', N'Ghi chú phiếu 1'),
(N'PTT2', N'CN10', 1656908, '2025-10-23', N'Ghi chú phiếu 2'),
(N'PTT3', N'CN10', 731085, '2025-03-08', N'Ghi chú phiếu 3'),
(N'PTT4', N'CN7', 471717, '2025-01-09', N'Ghi chú phiếu 4'),
(N'PTT5', N'CN8', 527239, '2025-09-02', N'Ghi chú phiếu 5'),
(N'PTT6', N'CN2', 1295961, '2025-09-15', N'Ghi chú phiếu 6'),
(N'PTT7', N'CN8', 311815, '2025-04-09', N'Ghi chú phiếu 7'),
(N'PTT8', N'CN1', 1983367, '2025-10-02', N'Ghi chú phiếu 8'),
(N'PTT9', N'CN2', 524997, '2025-04-04', N'Ghi chú phiếu 9'),
(N'PTT10', N'CN7', 357240, '2025-01-17', N'Ghi chú phiếu 10');




-----Stored Procedure---
/*Tìm sản phẩm theo khoảng giá*/
go
CREATE PROCEDURE usp_TimSanPhamTheoGia
    @GiaMin MONEY,
    @GiaMax MONEY
AS
BEGIN
IF @GiaMin > @GiaMax
BEGIN
RAISERROR (N'Gia Min khong duoc lon hon Gia Max',16,1);
RETURN;
END
    SET NOCOUNT ON;

    SELECT MASP, TENSP, GIABAN, SOLUONG
    FROM SANPHAM
    WHERE GIABAN BETWEEN @GiaMin AND @GiaMax
    ORDER BY GIABAN ASC;
END
EXEC usp_TimSanPhamTheoGia @GiaMin = 5000, @GiaMax = 30000;
go
/* Tính doanh thu theo ngày hoặc khoảng thời gian */
CREATE PROCEDURE usp_ThongKeDoanhThu
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        CAST(h.NGAYLAP AS DATE) AS Ngay,
        SUM(ct.SOLUONG * ct.DONGIA) AS DoanhThu,
        (
            ISNULL(SUM(ct.SOLUONG * ct.DONGIA), 0)
            - ISNULL(SUM(ctn.SOLUONGTN * ctn.DONGIANHAP), 0)
        ) AS LoiNhuan
    FROM HDBAN h
    JOIN CHITIETHDBAN ct ON h.MAHD = ct.MAHD
    LEFT JOIN HDNHAP n ON CAST(h.NGAYLAP AS DATE) = CAST(n.NGAYLAP AS DATE)
    LEFT JOIN CHITIETHDNHAP ctn ON n.MAHDNHAP = ctn.MAHDNHAP
    WHERE h.NGAYLAP BETWEEN @TuNgay AND @DenNgay
    GROUP BY CAST(h.NGAYLAP AS DATE);
END

EXEC usp_ThongKeDoanhThu @TuNgay = '2025-09-01', @DenNgay = '2025-10-10';

-----User-defined Function----
/*Lấy tuổi nhân viên từ ngày sinh*/
go
CREATE FUNCTION dbo.ufn_TinhTuoi(@NgaySinh DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Tuoi INT;
    SET @Tuoi = DATEDIFF(YEAR, @NgaySinh, GETDATE());
    -- Nếu chưa tới sinh nhật năm nay thì trừ 1
    IF (MONTH(@NgaySinh) > MONTH(GETDATE()))
       OR (MONTH(@NgaySinh) = MONTH(GETDATE()) AND DAY(@NgaySinh) > DAY(GETDATE()))
        SET @Tuoi = @Tuoi - 1;
    RETURN @Tuoi;
END
SELECT HOTEN, dbo.ufn_TinhTuoi(NGAYSINH) AS TUOI FROM NGUOIDUNG;

drop procedure usp_SanPhamSapHetHan

----Cursor----
/*Liệt kê sản phẩm sắp hết hạn (HSD < 30 ngày)*/
go
CREATE OR ALTER PROCEDURE usp_SanPhamSapHetHan
    @NgayHetHan INT 
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH SP_HSD AS (
        SELECT
            sp.MASP,sp.TENSP,sp.MALOAI,l.TENLOAI,sp.NSX,l.HSD_NGAY,
            HSD = DATEADD(DAY, l.HSD_NGAY, sp.NSX)
        FROM SANPHAM sp
        JOIN LOAISANPHAM l ON l.MALOAI = sp.MALOAI
        WHERE sp.NSX IS NOT NULL
          AND l.HSD_NGAY IS NOT NULL
    )
    SELECT
        MASP,TENSP,MALOAI,TENLOAI,NSX,HSD_NGAY,HSD,
        NgayConLai = DATEDIFF(DAY, CAST(GETDATE() AS DATE), HSD)
    FROM SP_HSD
    WHERE HSD <= DATEADD(DAY, @NgayHetHan, CAST(GETDATE() AS DATE))
    ORDER BY HSD ASC;  -- món nào sắp/đã hết hạn lên trước
END
GO

EXEC usp_SanPhamSapHetHan @NgayHetHan = 90;


-----NhanVien
---Lịch làm trong tuần(x)
CREATE PROC sp_LichLam_GetByWeek
    @Role NVARCHAR(10),
    @Username NVARCHAR(50),
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @Role = N'ADMIN'
    BEGIN
        SELECT L.MALICH, N.HOTEN, L.NGAYLAM, L.CALAM, L.GIOVAO, L.GIORA, L.GHICHU
        FROM LICHLAM L
        JOIN NGUOIDUNG N ON L.NGUOIDUNG_ID = N.ID
        WHERE L.NGAYLAM BETWEEN @TuNgay AND @DenNgay
        ORDER BY L.NGAYLAM;
    END
    ELSE
    BEGIN
        SELECT L.MALICH, N.HOTEN, L.NGAYLAM, L.CALAM, L.GIOVAO, L.GIORA, L.GHICHU
        FROM LICHLAM L
        JOIN NGUOIDUNG N ON L.NGUOIDUNG_ID = N.ID
        WHERE N.USERNAME = @Username
          AND L.NGAYLAM BETWEEN @TuNgay AND @DenNgay
        ORDER BY L.NGAYLAM;
    END
END
GO

---Chấm công
CREATE PROCEDURE sp_ChamCong --(x)
    @Username NVARCHAR(20),
    @NgayLam DATE,
    @GioVao TIME,
    @GioRa TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NguoiDungId INT;
    DECLARE @LichLamId INT;

    -- Lấy ID nhân viên và lịch làm
    SELECT TOP 1 
        @NguoiDungId = u.ID,
        @LichLamId = l.MALICH
    FROM NGUOIDUNG u
    INNER JOIN LICHLAM l ON l.NGUOIDUNG_ID = u.ID
    WHERE u.USERNAME = @Username AND l.NGAYLAM = @NgayLam;

    IF @NguoiDungId IS NULL OR @LichLamId IS NULL
    BEGIN
        RAISERROR(N'Nhân viên không có lịch làm trong ngày!', 16, 1);
        RETURN;
    END

    -- Kiểm tra đã chấm công chưa
    IF EXISTS (SELECT 1 FROM CHAMCONG WHERE LICHLAM_ID = @LichLamId)
    BEGIN
        RAISERROR(N'Lịch làm này đã được chấm công rồi!', 16, 1);
        RETURN;
    END

    -- Insert dữ liệu, C# sẽ quyết định trạng thái và số giờ
    INSERT INTO CHAMCONG (MANV, LICHLAM_ID, NGAYLAM, GIOVAO, GIORA, SOGIO, TRANGTHAI)
    VALUES (@NguoiDungId, @LichLamId, @NgayLam, @GioVao, @GioRa, 0, NULL);
END
GO

--Thống kê lương(x)
--CREATE OR ALTER PROCEDURE SP_ThongKeLuong
CREATE OR ALTER PROCEDURE SP_ThongKeLuong
    @thang INT,
    @nam INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tổng hợp chấm công theo ngày
    WITH CC AS (
        SELECT 
            MANV,
            NGAYLAM,
            COUNT(*) AS SoCa,
            SUM(CASE WHEN TRANGTHAI = N'Đúng giờ' THEN 1 ELSE 0 END) AS CaDungGio,
            SUM(CASE WHEN TRANGTHAI = N'Muộn' THEN 1 ELSE 0 END) AS CaTre,
            SUM(CASE WHEN TRANGTHAI = N'Vắng' THEN 1 ELSE 0 END) AS CaVang
        FROM CHAMCONG
        WHERE MONTH(NGAYLAM) = @thang AND YEAR(NGAYLAM) = @nam
        GROUP BY MANV, NGAYLAM
    ),

    Luong AS (
        SELECT 
            N.ID AS MANV,
            N.HOTEN,
            N.LUONG AS LuongThang,
            CC.NGAYLAM,

            -- Lương ngày = Lương tháng / 26
            (N.LUONG / 26.0) AS LuongNgay,

            -- Lương 1 ca (nếu có 2 ca thì chia đôi)
            CASE 
                WHEN CC.SoCa = 2 THEN (N.LUONG / 26.0) / 2
                ELSE (N.LUONG / 26.0)
            END AS Luong1Ca,

            -- Lương thực tế
            (
                (CC.CaDungGio * 
                    CASE WHEN CC.SoCa = 2 THEN (N.LUONG / 26.0) / 2 ELSE (N.LUONG / 26.0) END
                ) +

                (CC.CaTre * 
                    CASE WHEN CC.SoCa = 2 THEN ((N.LUONG / 26.0) / 2) * 0.85 
                         ELSE (N.LUONG / 26.0) * 0.85 
                    END
                )

                -- Ca vắng = 0
            ) AS LuongNgayThucTe
        FROM CC
        JOIN NGUOIDUNG N ON CC.MANV = N.ID
    )

    SELECT 
        MANV, HOTEN,
        LuongThang,
        COUNT(NGAYLAM) AS NgayCoCong,
        SUM(LuongNgayThucTe) AS LuongThucTe
    FROM Luong
    GROUP BY MANV, HOTEN, LuongThang
    ORDER BY HOTEN;

END;


CREATE TRIGGER TRG_LICHLAM_KHONG_THEM_QUA_KHU
ON LICHLAM
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu NGAYLAM < hôm nay thì chặn
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE NGAYLAM < CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Không thể thêm lịch làm trong quá khứ!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

CREATE TRIGGER TRG_LICHLAM_KHONG_UPDATE_QUA_KHU
ON LICHLAM
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu NGAYLAM bị sửa thành ngày trong quá khứ → chặn
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE NGAYLAM < CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Không thể cập nhật lịch làm về ngày trong quá khứ!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;





select * from V_TONKHO;
select * from VIEW_ThongKeDoanhThu;
select * from V_CONGNO_PHAITRA;
select * from V_SANPHAM_NHACUNGCAP;
select * from V_SANPHAM_HSD

select * from NGUOIDUNG
select * from VAITRO
select * from TAIKHOAN 
select * from NHACUNGCAP
select * from LOAISANPHAM
select * from SANPHAM
select * from HDNHAP
select * from CHITIETHDNHAP
select * from HDBAN
select * from CHITIETHDBAN
select * from CONGNO
select * from PHIEUTHANHTOAN


SELECT 
    name,
    type_desc,
    create_date
FROM sys.objects
WHERE type IN ('P','FN','TF','TR')  -- Procedure, Function, TableFunc, Trigger
ORDER BY type_desc, name;
