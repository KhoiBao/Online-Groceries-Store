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




        public ActionResult Login()
        {
            // Kiểm tra nếu đã đăng nhập rồi thì chuyển hướng
            if (Session["User"] != null)
            {
                return RedirectToAction("Index"); // Hoặc trang dashboard
            }
            return View();
        }

        // POST: /Home/Login
        // Xử lý thông tin đăng nhập
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(TAIKHOAN model)
        {
            // 1. Kiểm tra dữ liệu đầu vào (ModelState) - Nếu bạn có dùng Data Annotations trong Model
            if (string.IsNullOrEmpty(model.USERNAME) || string.IsNullOrEmpty(model.PASSWORD))
            {
                ViewBag.Error = "Vui lòng nhập đầy đủ Tên đăng nhập và Mật khẩu.";
                return View(model);
            }

            // 2. Tìm tài khoản trong Database
            // Lưu ý: Trong thực tế, bạn nên mã hóa mật khẩu trước khi lưu và so sánh.
            // Ở đây, tôi đang giả định mật khẩu được lưu dưới dạng Plain Text để phù hợp với code hiện tại.
            var account = db.TAIKHOANs
                            .SingleOrDefault(tk => tk.USERNAME == model.USERNAME && tk.PASSWORD == model.PASSWORD);

            // 3. Xử lý kết quả tìm kiếm
            if (account != null)
            {
                // Kiểm tra trạng thái tài khoản
                if (account.TRANGTHAI == "KHOA") // Giả định trạng thái bị khóa là "KHOA"
                {
                    ViewBag.Error = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.";
                    return View(model);
                }

                // Đăng nhập thành công: Lưu thông tin vào Session
                // Lưu đối tượng TAIKHOAN vào Session.
                Session["User"] = account;
                // Lưu Tên người dùng và Role (quyền) nếu cần hiển thị trên UI
                Session["Username"] = account.USERNAME;
                Session["Role"] = account.MAROLE;

                // Chuyển hướng về trang chủ hoặc trang sau khi đăng nhập
                return RedirectToAction("Index", "Home");
            }
            else
            {
                // Đăng nhập thất bại
                ViewBag.Error = "Tên đăng nhập hoặc Mật khẩu không đúng.";
                return View(model);
            }
        }

        // ===============================
        // ĐĂNG XUẤT
        // ===============================

        // GET: /Home/Logout
        public ActionResult Logout()
        {
            // Xóa tất cả Session liên quan đến người dùng
            Session.Clear();
            Session.Abandon();
            // Chuyển hướng về trang chủ hoặc trang đăng nhập
            return RedirectToAction("Index", "Home");
        }


        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }



        public List<ItemGioHang> LayGioHang()
        {
            // Giỏ hàng được lưu dưới Session["GioHang"]
            List<ItemGioHang> lstGioHang = Session["GioHang"] as List<ItemGioHang>;

            if (lstGioHang == null)
            {
                // Nếu Giỏ hàng chưa tồn tại, khởi tạo mới
                lstGioHang = new List<ItemGioHang>();
                Session["GioHang"] = lstGioHang;
            }
            return lstGioHang;
        }


        /// <summary>
        /// Thêm sản phẩm vào giỏ hàng.
        /// </summary>
        /// <param name="id">Mã sản phẩm (MASP) cần thêm.</param>
        /// <param name="strURL">URL trang hiện tại để quay lại.</param>
        /// <returns></returns>
        public ActionResult ThemGioHang(string id, string strURL)
        {
            // 1. Lấy Giỏ hàng hiện tại
            List<ItemGioHang> lstGioHang = LayGioHang();

            // 2. Kiểm tra sản phẩm đã có trong giỏ chưa
            ItemGioHang sanPham = lstGioHang.Find(sp => sp.MaSP == id);

            if (sanPham == null)
            {
                // Sản phẩm chưa có trong giỏ -> Thêm mới
                sanPham = new ItemGioHang(id);
                if (sanPham.TenSP == null)
                {
                    // Xử lý nếu ID sản phẩm không hợp lệ
                    return HttpNotFound("Không tìm thấy sản phẩm.");
                }
                lstGioHang.Add(sanPham);
            }
            else
            {
                // Sản phẩm đã có trong giỏ -> Tăng số lượng lên 1
                sanPham.SoLuong++;
            }

            // 3. Quay lại trang vừa rồi (hoặc chuyển hướng đến trang giỏ hàng)
            if (string.IsNullOrEmpty(strURL))
            {
                return RedirectToAction("Index", "Home");
            }
            return Redirect(strURL);
        }

        /// <summary>
        /// Hiển thị trang Giỏ hàng.
        /// </summary>
        public ActionResult GioHang()
        {
            List<ItemGioHang> lstGioHang = LayGioHang();
            if (lstGioHang.Count == 0)
            {
                ViewBag.ThongBao = "Giỏ hàng của bạn đang trống!";
            }
            return View(lstGioHang);
        }

        // File: Controllers/HomeController.cs (Bổ sung vào class HomeController)

        // ... (Các Action hiện có như LayGioHang, ThemGioHang, GioHang)

        /// <summary>
        /// Xóa một sản phẩm cụ thể khỏi giỏ hàng theo Mã sản phẩm (MASP).
        /// </summary>
        /// <param name="id">Mã sản phẩm (MASP) cần xóa.</param>
        /// <returns></returns>
        public ActionResult XoaGioHang(string id)
        {
            // 1. Lấy danh sách Giỏ hàng
            List<ItemGioHang> lstGioHang = LayGioHang();

            // 2. Tìm sản phẩm cần xóa theo MaSP
            ItemGioHang sanPham = lstGioHang.SingleOrDefault(sp => sp.MaSP == id);

            if (sanPham != null)
            {
                // 3. Xóa sản phẩm khỏi danh sách
                lstGioHang.Remove(sanPham);
            }

            // 4. Kiểm tra nếu Giỏ hàng trống thì xóa Session["GioHang"] luôn
            if (lstGioHang.Count == 0)
            {
                Session["GioHang"] = null;
            }

            // 5. Quay lại trang Giỏ hàng để hiển thị kết quả
            return RedirectToAction("GioHang");
        }

        // File: Controllers/HomeController.cs (Bổ sung vào class HomeController)

        // ... (Các Action hiện có)

        /// <summary>
        /// Xóa toàn bộ sản phẩm trong Giỏ hàng (Clear Session["GioHang"]).
        /// </summary>
        public ActionResult XoaTatCaGioHang()
        {
            // Xóa Session["GioHang"]
            Session["GioHang"] = null;

            // Quay lại trang Giỏ hàng
            return RedirectToAction("GioHang");
        }


        // File: Controllers/HomeController.cs (Bổ sung)

        /// <summary>
        /// Hiển thị danh sách sản phẩm theo Tên Loại Sản Phẩm.
        /// </summary>
        /// <param name="tenLoai">Tên Loại Sản Phẩm (TÊNLOAI) cần lọc.</param>
        /// <returns></returns>
        public ActionResult SanPhamTheoLoai(string tenLoai)
        {
            if (string.IsNullOrEmpty(tenLoai))
            {
                // Nếu không có tên loại, chuyển hướng về trang chủ hoặc trang Sản phẩm chung
                return RedirectToAction("Index");
            }

            // 1. Truy vấn sản phẩm theo TÊN LOẠI
            // Lưu ý: TÊNLOAI phải khớp chính xác với dữ liệu trong DB
            var listProducts = db.SANPHAMs
                                 .Where(p => p.LOAISANPHAM.TENLOAI == tenLoai)
                                 .ToList();

            // 2. Truyền tên loại sản phẩm sang View để hiển thị tiêu đề
            ViewBag.TenLoai = tenLoai;

            // 3. Truyền danh sách sản phẩm đã lọc sang View
            if (listProducts.Count == 0)
            {
                ViewBag.Message = $"Không tìm thấy sản phẩm nào thuộc loại '{tenLoai}'.";
            }

            return View("SanPhamTheoLoaiView", listProducts); // Sử dụng một View chung để hiển thị kết quả
        }


    }
}