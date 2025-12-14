// File: Models/ItemGioHang.cs

using DoAnCNPM.Models;
using System.Linq;

namespace DoAnCNPM.Models
{
    public class ItemGioHang
    {
        // Thuộc tính chính
        public string MaSP { get; set; }
        public string TenSP { get; set; }
        public string Hinh { get; set; } // Thuộc tính hình ảnh được thêm vào
        public decimal DonGia { get; set; }
        public int SoLuong { get; set; }
        public decimal ThanhTien
        {
            get { return SoLuong * DonGia; }
        }

        // ==============================================
        // CONSTRUCTOR 1: KHI THÊM 1 SẢN PHẨM (1 tham số)
        // ==============================================
        public ItemGioHang(string maSP)
        {
            MaSP = maSP;
            using (var db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1())
            {
                var sp = db.SANPHAMs.SingleOrDefault(p => p.MASP == maSP);
                if (sp != null)
                {
                    TenSP = sp.TENSP;
                    Hinh = sp.HINH; // Gán hình ảnh
                    DonGia = (decimal)sp.GIABAN;
                    SoLuong = 1; // Mặc định thêm 1 sản phẩm
                }
            }
        }

        // ==============================================
        // CONSTRUCTOR 2: KHI THÊM NHIỀU SẢN PHẨM (2 tham số)
        // Đây là hàm cần thiết để khắc phục lỗi của bạn
        // ==============================================
        public ItemGioHang(string maSP, int soLuongMoi)
        {
            MaSP = maSP;
            using (var db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1())
            {
                var sp = db.SANPHAMs.SingleOrDefault(p => p.MASP == maSP);
                if (sp != null)
                {
                    TenSP = sp.TENSP;
                    Hinh = sp.HINH; // Gán hình ảnh
                    DonGia = (decimal)sp.GIABAN;
                    SoLuong = soLuongMoi; // Gán số lượng được truyền vào
                }
                else
                {
                    // Đặt các thuộc tính về null/0 nếu không tìm thấy sản phẩm, 
                    // để Controller có thể kiểm tra (nếu TenSP == null)
                    TenSP = null;
                    DonGia = 0;
                    SoLuong = 0;
                }
            }
        }
    }
}