using DoAnCNPM.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity.Validation; // Cần thiết để bắt lỗi DbEntityValidationException

namespace DoAnCNPM.Controllers
{
    public class HomeController : Controller
    {
        // Khai báo DbContext
        QL_SIEUTHIMINI_TIEMTAPHOAEntities1 db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1();
<<<<<<< Updated upstream
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

=======

       




        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        // ===============================
        // TRANG CHỦ VÀ CHI TIẾT
        // ===============================

        public ActionResult Index(string searchQuery)
        {
            using (var dbContext = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1())
            {
                IQueryable<SANPHAM> products = dbContext.SANPHAMs;

                if (!string.IsNullOrEmpty(searchQuery))
                {
                    ViewBag.CurrentFilter = searchQuery;
                    products = products.Where(p => p.TENSP.Contains(searchQuery));
                }

                var categorizedProducts = products
                    .GroupBy(p => p.LOAISANPHAM.TENLOAI)
                    .ToDictionary(g => g.Key, g => g.ToList());

                ViewBag.CategorizedProducts = categorizedProducts;
            }
            return View();
        }

        public ActionResult Details(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return HttpNotFound();
            }

            var product = db.SANPHAMs.SingleOrDefault(p => p.MASP == id);

            if (product == null)
            {
                return HttpNotFound();
            }

            return View(product);
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";
>>>>>>> Stashed changes
            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
            return View();
        }

        public ActionResult SanPham()
        {
<<<<<<< Updated upstream

            var listsp = db.SANPHAMs.ToList();
            return View(listsp);
        }
=======
            var listsp = db.SANPHAMs.ToList();
            return View(listsp);
        }

        // ===============================
        // TÌM KIẾM SẢN PHẨM
        // ===============================
        public ActionResult Search(string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword))
            {
                ViewBag.Keyword = "";
                ViewBag.Message = "Vui lòng nhập từ khóa tìm kiếm";
                return View(new List<SANPHAM>());
            }

            var result = db.SANPHAMs
                .Where(p => p.TENSP.Contains(keyword)
                             || p.LOAISANPHAM.TENLOAI.Contains(keyword))
                .ToList();

            ViewBag.Keyword = keyword;
            return View(result);
        }

        // ===============================
        // SẢN PHẨM THEO LOẠI
        // ===============================
        public ActionResult SanPhamTheoLoai(string tenLoai)
        {
            if (string.IsNullOrEmpty(tenLoai))
            {
                return RedirectToAction("Index");
            }

            var listProducts = db.SANPHAMs
                                 .Where(p => p.LOAISANPHAM.TENLOAI == tenLoai)
                                 .ToList();

            ViewBag.TenLoai = tenLoai;

            if (listProducts.Count == 0)
            {
                ViewBag.Message = $"Không tìm thấy sản phẩm nào thuộc loại '{tenLoai}'.";
            }

            return View("SanPhamTheoLoaiView", listProducts);
        }

        // ===============================
        // ĐĂNG NHẬP (ĐÃ CẬP NHẬT CHUYỂN HƯỚNG)
        // ===============================

        public ActionResult Login()
        {
            if (Session["User"] != null)
            {
                return RedirectToAction("Index");
            }
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(TAIKHOAN model)
        {
            if (string.IsNullOrEmpty(model.USERNAME) || string.IsNullOrEmpty(model.PASSWORD))
            {
                ViewBag.Error = "Vui lòng nhập đầy đủ Tên đăng nhập và Mật khẩu.";
                return View(model);
            }

            var account = db.TAIKHOANs
                            .SingleOrDefault(tk => tk.USERNAME == model.USERNAME && tk.PASSWORD == model.PASSWORD);

            if (account != null)
            {
                if (account.TRANGTHAI == "KHOA")
                {
                    ViewBag.Error = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.";
                    return View(model);
                }

                Session["User"] = account;
                Session["Username"] = account.USERNAME;
                Session["Role"] = account.MAROLE;

                // XỬ LÝ CHUYỂN HƯỚNG QUAY LẠI SAU KHI ĐĂNG NHẬP THÀNH CÔNG
                string returnUrl = TempData["ReturnUrl"] as string;

                if (!string.IsNullOrEmpty(returnUrl))
                {
                    return Redirect(returnUrl);
                }

                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Error = "Tên đăng nhập hoặc Mật khẩu không đúng.";
                return View(model);
            }
        }

        // ===============================
        // ĐĂNG KÝ (MỚI)
        // ===============================

        // GET: /Home/Register (Hiển thị form đăng ký)
        public ActionResult Register()
        {
            if (Session["User"] != null)
            {
                return RedirectToAction("Index");
            }
            return View();
        }

        // POST: /Home/Register (Xử lý dữ liệu đăng ký)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(TAIKHOAN newAccount)
        {
            if (ModelState.IsValid)
            {
                // 1. Kiểm tra tên đăng nhập đã tồn tại chưa
                var existingUser = db.TAIKHOANs.SingleOrDefault(tk => tk.USERNAME == newAccount.USERNAME);

                if (existingUser != null)
                {
                    ViewBag.Error = "Tên đăng nhập này đã được sử dụng. Vui lòng chọn tên khác.";
                    return View(newAccount);
                }

                // 2. Thiết lập các giá trị mặc định cho tài khoản mới
                newAccount.TRANGTHAI = "HOATDONG"; // Gán giá trị bắt buộc/mặc định (Nếu TRANGTHAI là NOT NULL trong DB)
                newAccount.MAROLE = "KH";       // Gán vai trò mặc định (Phải tồn tại trong bảng VAITRO)

                try
                {
                    // 3. Lưu tài khoản vào cơ sở dữ liệu
                    db.TAIKHOANs.Add(newAccount);
                    db.SaveChanges();

                    // 4. Đăng ký thành công, tự động đăng nhập và chuyển hướng về trang chủ
                    Session["User"] = newAccount;
                    Session["Username"] = newAccount.USERNAME;
                    Session["Role"] = newAccount.MAROLE;

                    return RedirectToAction("Index", "Home");
                }
                catch (DbEntityValidationException ex)
                {
                    // XỬ LÝ LỖI VALIDATION CHI TIẾT
                    var errorMessages = ex.EntityValidationErrors
                        .SelectMany(x => x.ValidationErrors)
                        .Select(x => x.PropertyName + ": " + x.ErrorMessage);

                    var fullErrorMessage = string.Join("; ", errorMessages);
                    ViewBag.Error = "Đăng ký thất bại do lỗi Validation: " + fullErrorMessage;

                    return View(newAccount);
                }
                catch (Exception ex)
                {
                    // Xử lý lỗi hệ thống chung
                    ViewBag.Error = "Đã xảy ra lỗi hệ thống. Vui lòng thử lại. Lỗi: " + ex.Message;
                    return View(newAccount);
                }
            }

            // Nếu Model không hợp lệ (ví dụ: thiếu trường bắt buộc trên Model)
            return View(newAccount);
        }

        // ===============================
        // ĐĂNG XUẤT
        // ===============================
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index", "Home");
        }


        // ===============================
        // CHỨC NĂNG GIỎ HÀNG (ĐÃ THÊM KIỂM TRA ĐĂNG NHẬP)
        // ===============================
        public List<ItemGioHang> LayGioHang()
        {
            List<ItemGioHang> lstGioHang = Session["GioHang"] as List<ItemGioHang>;

            if (lstGioHang == null)
            {
                lstGioHang = new List<ItemGioHang>();
                Session["GioHang"] = lstGioHang;
            }
            return lstGioHang;
        }


        public ActionResult ThemGioHang(string id, int soLuong = 1, string strURL = "")
        {
            // BƯỚC 1: KIỂM TRA ĐĂNG NHẬP
            if (Session["User"] == null)
            {
                // Lưu lại URL trang hiện tại (strURL) vào TempData
                TempData["ReturnUrl"] = strURL;

                // Chuyển hướng đến trang đăng nhập
                return RedirectToAction("Login", "Home");
            }

            if (soLuong <= 0)
            {
                soLuong = 1;
            }

            // 2. Lấy Giỏ hàng hiện tại
            List<ItemGioHang> lstGioHang = LayGioHang();

            // 3. Kiểm tra sản phẩm đã có trong giỏ chưa
            ItemGioHang sanPham = lstGioHang.Find(sp => sp.MaSP == id);

            if (sanPham == null)
            {
                sanPham = new ItemGioHang(id, soLuong);

                if (sanPham.TenSP == null)
                {
                    return HttpNotFound("Không tìm thấy sản phẩm.");
                }
                lstGioHang.Add(sanPham);
            }
            else
            {
                sanPham.SoLuong += soLuong;
            }

            // 4. Quay lại trang vừa rồi
            if (string.IsNullOrEmpty(strURL))
            {
                if (Request.UrlReferrer != null)
                {
                    return Redirect(Request.UrlReferrer.ToString());
                }
                return RedirectToAction("Index", "Home");
            }
            return Redirect(strURL);
        }

        public ActionResult GioHang()
        {
            List<ItemGioHang> lstGioHang = LayGioHang();
            if (lstGioHang.Count == 0)
            {
                ViewBag.ThongBao = "Giỏ hàng của bạn đang trống!";
            }
            return View(lstGioHang);
        }

        public ActionResult XoaGioHang(string id)
        {
            List<ItemGioHang> lstGioHang = LayGioHang();
            ItemGioHang sanPham = lstGioHang.SingleOrDefault(sp => sp.MaSP == id);

            if (sanPham != null)
            {
                lstGioHang.Remove(sanPham);
            }

            if (lstGioHang.Count == 0)
            {
                Session["GioHang"] = null;
            }
            return RedirectToAction("GioHang");
        }

        public ActionResult XoaTatCaGioHang()
        {
            Session["GioHang"] = null;
            return RedirectToAction("GioHang");
        }


        // Trong file HomeController.cs

        // ... (Các Action Login/Register ở trên) ...

        // ===============================
        // QUÊN MẬT KHẨU
        // ===============================

        // GET: /Home/ForgotPassword (Hiển thị form nhập Email)
        public ActionResult ForgotPassword()
        {
            return View();
        }

        // POST: /Home/ForgotPassword (Xử lý kiểm tra Email)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ForgotPassword(string Email)
        {
            if (string.IsNullOrEmpty(Email))
            {
                ViewBag.Error = "Vui lòng nhập địa chỉ Email đăng ký.";
                return View();
            }

            // 1. Tìm kiếm tài khoản theo Email
            var account = db.TAIKHOANs.SingleOrDefault(tk => tk.EMAIL == Email);

            if (account != null)
            {
                // 2. Lưu Email vào Session hoặc TempData để truyền sang trang Reset
                // Trong thực tế: Bạn sẽ gửi token xác thực qua email ở bước này.
                // Trong demo: Chúng ta giả định xác thực thành công và chuyển thẳng sang Reset
                Session["ResetEmail"] = Email;

                // Chuyển hướng đến trang đặt lại mật khẩu
                return RedirectToAction("ResetPassword");
            }
            else
            {
                ViewBag.Error = "Không tìm thấy tài khoản nào được đăng ký với Email này.";
                return View();
            }
        }

        // ===============================
        // ĐẶT LẠI MẬT KHẨU
        // ===============================

        // GET: /Home/ResetPassword (Hiển thị form nhập mật khẩu mới)
        public ActionResult ResetPassword()
        {
            // Yêu cầu phải đi qua bước ForgotPassword trước
            if (Session["ResetEmail"] == null)
            {
                return RedirectToAction("ForgotPassword");
            }
            return View();
        }

        // POST: /Home/ResetPassword (Xử lý cập nhật mật khẩu mới)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ResetPassword(string NewPassword, string ConfirmPassword)
        {
            string emailToReset = Session["ResetEmail"] as string;

            // 1. Kiểm tra session/email hợp lệ
            if (string.IsNullOrEmpty(emailToReset))
            {
                ViewBag.Error = "Phiên đặt lại đã hết hạn. Vui lòng thử lại từ bước Quên Mật khẩu.";
                return View();
            }

            // 2. Kiểm tra mật khẩu
            if (string.IsNullOrEmpty(NewPassword) || string.IsNullOrEmpty(ConfirmPassword))
            {
                ViewBag.Error = "Vui lòng nhập đầy đủ Mật khẩu mới và Xác nhận mật khẩu.";
                return View();
            }
            if (NewPassword != ConfirmPassword)
            {
                ViewBag.Error = "Mật khẩu mới và Xác nhận mật khẩu không khớp.";
                return View();
            }
            if (NewPassword.Length < 6) // Ví dụ: yêu cầu mật khẩu tối thiểu 6 ký tự
            {
                ViewBag.Error = "Mật khẩu phải có tối thiểu 6 ký tự.";
                return View();
            }

            // 3. Tìm kiếm tài khoản và cập nhật mật khẩu
            var account = db.TAIKHOANs.SingleOrDefault(tk => tk.EMAIL == emailToReset);

            if (account != null)
            {
                try
                {
                    // Cập nhật mật khẩu mới (TRONG THỰC TẾ: PHẢI HASH MẬT KHẨU TRƯỚC KHI LƯU)
                    account.PASSWORD = NewPassword;
                    db.SaveChanges();

                    // Xóa session và chuyển hướng đến trang Đăng nhập
                    Session.Remove("ResetEmail");
                    TempData["SuccessMessage"] = "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.";
                    return RedirectToAction("Login");
                }
                catch (Exception ex)
                {
                    ViewBag.Error = "Lỗi khi cập nhật mật khẩu. Vui lòng thử lại. Lỗi: " + ex.Message;
                    return View();
                }
            }

            // Trường hợp không tìm thấy tài khoản (dù đã kiểm tra ở bước trước)
            ViewBag.Error = "Lỗi hệ thống: Không tìm thấy tài khoản.";
            return View();
        }
>>>>>>> Stashed changes
    }
}