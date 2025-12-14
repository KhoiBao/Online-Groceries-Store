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
        public decimal DonGia { get; set; }
        public int SoLuong { get; set; }
        public decimal ThanhTien
        {
            get { return SoLuong * DonGia; }
        }

        // Tạo Constructor để khởi tạo item từ MaSP
        public ItemGioHang(string maSP)
        {
            MaSP = maSP;
            using (var db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1())
            {
                var sp = db.SANPHAMs.SingleOrDefault(p => p.MASP == maSP);
                if (sp != null)
                {
                    TenSP = sp.TENSP;
                    // Lấy giá bán (giả định là GIA_BAN)
                    DonGia = (decimal)sp.GIABAN;
                    SoLuong = 1; // Mặc định thêm 1 sản phẩm
                }
            }
        }
    }
}