using DoAnCNPM.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAnCNPM.Controllers
{
    public class HomeController : Controller
    {
        QL_SIEUTHIMINI_TIEMTAPHOAEntities1 db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1();
        

        public ActionResult Index()
        {
            using (var db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1())
            {
                // Truy vấn dữ liệu từ DB
                var allProducts = db.SANPHAMs.ToList(); // Lấy tất cả sản phẩm

                // Nhóm sản phẩm theo tên loại (sử dụng đối tượng SANPHAM của Model)
                var categorizedProducts = allProducts
                    .GroupBy(p => p.LOAISANPHAM.TENLOAI) // Vẫn nhóm theo TENLOAI
                    .ToDictionary(g => g.Key, g => g.ToList());

                ViewBag.CategorizedProducts = categorizedProducts;
            }
            return View();
        }

        public ActionResult Details(string id) // Giả định ID là chuỗi (string) theo tên cột
        {
            if (string.IsNullOrEmpty(id))
            {
                // Trả về lỗi 404 hoặc trang không tìm thấy
                return HttpNotFound();
            }

            // 1. Truy vấn sản phẩm theo ID
            var product = db.SANPHAMs.SingleOrDefault(p => p.MASP == id);

            if (product == null)
            {
                // Trả về lỗi 404 nếu không tìm thấy sản phẩm
                return HttpNotFound();
            }

            // 2. Truyền đối tượng SANPHAM chi tiết sang View
            return View(product);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }


        public ActionResult About() 
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult SanPham()
        {

            var listsp = db.SANPHAMs.ToList();
            return View(listsp);
        }


        // ===============================
        // TÌM KIẾM SẢN PHẨM
        // ===============================
        public ActionResult Search(string keyword)
        {
            // Nếu không nhập từ khóa
            if (string.IsNullOrWhiteSpace(keyword))
            {
                ViewBag.Keyword = "";
                ViewBag.Message = "Vui lòng nhập từ khóa tìm kiếm";
                return View(new List<SANPHAM>());
            }

            // Tìm theo TÊN SẢN PHẨM (và có thể theo TÊN LOẠI)
            var result = db.SANPHAMs
                .Where(p => p.TENSP.Contains(keyword)
                         || p.LOAISANPHAM.TENLOAI.Contains(keyword))
                .ToList();

            ViewBag.Keyword = keyword;

            return View(result);
        }

    }
}