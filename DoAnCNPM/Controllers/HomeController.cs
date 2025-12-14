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

        public ActionResult admin()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        // ===============================
        // THANH TOÁN
        // ===============================

        // GET: /Home/ThanhToan
        public ActionResult ThanhToan()
        {
            try
            {
                // DEBUG
                System.Diagnostics.Debug.WriteLine("=== THANHTOAN GET ACTION ===");

                // 1. Kiểm tra đăng nhập
                if (Session["User"] == null)
                {
                    TempData["ReturnUrl"] = Url.Action("ThanhToan", "Home");
                    return RedirectToAction("Login");
                }

                List<ItemGioHang> lstGioHang;
                bool isQuickBuy = false;

                // 2. Kiểm tra xem có phải mua hàng nhanh không
                if (Session["GioHangMuaNhanh"] != null)
                {
                    // Trường hợp mua hàng nhanh (chỉ 1 sản phẩm)
                    lstGioHang = Session["GioHangMuaNhanh"] as List<ItemGioHang>;
                    isQuickBuy = true;
                    System.Diagnostics.Debug.WriteLine("Quick buy mode - Single product");
                }
                else
                {
                    // Trường hợp thanh toán toàn bộ giỏ hàng
                    lstGioHang = LayGioHang();
                    System.Diagnostics.Debug.WriteLine("Normal checkout - Full cart");
                }

                // 3. Kiểm tra giỏ hàng
                if (lstGioHang == null || lstGioHang.Count == 0)
                {
                    TempData["ErrorMessage"] = "Giỏ hàng của bạn đang trống!";
                    return RedirectToAction("GioHang");
                }

                // 4. Lấy thông tin user
                var currentUser = Session["User"] as TAIKHOAN;
                if (currentUser != null)
                {
                    ViewBag.FullName = currentUser.USERNAME;
                    ViewBag.Email = currentUser.EMAIL;
                    // Thêm các thông tin khác nếu có
                    // ViewBag.Phone = currentUser.SDT;
                }

                // 5. Tính toán tổng tiền
                ViewBag.CartItems = lstGioHang;
                ViewBag.ItemCount = lstGioHang.Count;
                ViewBag.SubTotal = lstGioHang.Sum(item => item.ThanhTien);
                ViewBag.ShippingFee = 30000;
                ViewBag.Total = ViewBag.SubTotal + ViewBag.ShippingFee;
                ViewBag.IsQuickBuy = isQuickBuy;

                System.Diagnostics.Debug.WriteLine($"Displaying ThanhToan view - {lstGioHang.Count} products");
                return View();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR in ThanhToan GET: {ex.Message}");
                TempData["ErrorMessage"] = "Lỗi hệ thống: " + ex.Message;
                return RedirectToAction("GioHang");
            }
        }

        // POST: /Home/ThanhToan - Xử lý đặt hàng
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThanhToan(FormCollection form)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== THANHTOAN POST ACTION ===");

                // 1. Kiểm tra đăng nhập
                if (Session["User"] == null)
                {
                    TempData["ErrorMessage"] = "Vui lòng đăng nhập để đặt hàng!";
                    return RedirectToAction("Login");
                }

                var currentUser = Session["User"] as TAIKHOAN;
                if (currentUser == null)
                {
                    TempData["ErrorMessage"] = "Thông tin người dùng không hợp lệ!";
                    return RedirectToAction("Login");
                }

                // 2. Lấy dữ liệu từ form
                string fullName = form["fullName"];
                string phone = form["phone"];
                string email = form["email"];
                string address = form["address"];
                string city = form["city"];
                string district = form["district"];
                string ward = form["ward"];
                string note = form["note"];
                string paymentMethod = form["paymentMethod"];

                // 3. Validate dữ liệu
                if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(phone) || string.IsNullOrEmpty(address))
                {
                    TempData["ErrorMessage"] = "Vui lòng điền đầy đủ thông tin bắt buộc!";
                    return RedirectToAction("ThanhToan");
                }

                System.Diagnostics.Debug.WriteLine($"Customer: {fullName}, Phone: {phone}, Email: {email}");

                // 4. Xác định nguồn giỏ hàng (mua hàng nhanh hay giỏ hàng thường)
                List<ItemGioHang> lstGioHang;
                bool isQuickBuy = Session["GioHangMuaNhanh"] != null;

                if (isQuickBuy)
                {
                    // Mua hàng nhanh - lấy từ session đặc biệt
                    lstGioHang = Session["GioHangMuaNhanh"] as List<ItemGioHang>;
                    System.Diagnostics.Debug.WriteLine("Processing quick buy order");
                }
                else
                {
                    // Thanh toán toàn bộ giỏ hàng
                    lstGioHang = LayGioHang();
                    System.Diagnostics.Debug.WriteLine("Processing full cart order");
                }

                // 5. Kiểm tra giỏ hàng
                if (lstGioHang == null || lstGioHang.Count == 0)
                {
                    TempData["ErrorMessage"] = "Giỏ hàng của bạn đang trống!";
                    return RedirectToAction("GioHang");
                }

                // 6. Tính toán tổng tiền
                decimal subtotal = lstGioHang.Sum(item => item.ThanhTien);
                decimal shippingFee = 30000;
                decimal totalAmount = subtotal + shippingFee;

                System.Diagnostics.Debug.WriteLine($"Subtotal: {subtotal}, Shipping: {shippingFee}, Total: {totalAmount}");

                // 7. Tạo mã đơn hàng
                string orderId = GenerateOrderId();
                System.Diagnostics.Debug.WriteLine($"Generated Order ID: {orderId}");

                // 8. Lưu thông tin đơn hàng vào database (nếu có)
                bool saveToDatabaseSuccess = false;
                string databaseOrderId = "";

                try
                {
                    // Thử lưu vào database nếu có cấu trúc phù hợp
                    databaseOrderId = SaveOrderToDatabase(orderId, currentUser.USERNAME, lstGioHang,
                                                         fullName, phone, email, address,
                                                         city, district, ward, note,
                                                         paymentMethod, totalAmount);

                    if (!string.IsNullOrEmpty(databaseOrderId))
                    {
                        saveToDatabaseSuccess = true;
                        orderId = databaseOrderId; // Sử dụng mã từ database
                    }
                }
                catch (Exception dbEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Database save failed: {dbEx.Message}");
                    // Vẫn tiếp tục với session nếu database lỗi
                }

                // 9. Lưu thông tin vào TempData để hiển thị ở trang xác nhận
                TempData["OrderSuccess"] = true;
                TempData["OrderId"] = orderId;
                TempData["TotalAmount"] = totalAmount;
                TempData["CustomerName"] = fullName;
                TempData["CustomerPhone"] = phone;
                TempData["CustomerEmail"] = email;
                TempData["CustomerAddress"] = $"{address}, {ward}, {district}, {city}";
                TempData["PaymentMethod"] = paymentMethod;
                TempData["OrderDate"] = DateTime.Now.ToString("dd/MM/yyyy HH:mm");
                TempData["ItemCount"] = lstGioHang.Count;
                TempData["SaveToDatabase"] = saveToDatabaseSuccess;

                // 10. Xóa giỏ hàng sau khi đặt hàng thành công
                if (isQuickBuy)
                {
                    // Xóa session mua hàng nhanh
                    Session.Remove("GioHangMuaNhanh");
                    System.Diagnostics.Debug.WriteLine("Quick buy session cleared");

                    // KHÔNG xóa giỏ hàng chính khi mua hàng nhanh
                    // Giữ nguyên giỏ hàng gốc cho người dùng
                }
                else
                {
                    // Xóa toàn bộ giỏ hàng khi thanh toán tất cả
                    Session["GioHang"] = null;
                    System.Diagnostics.Debug.WriteLine("Full cart cleared");
                }

                // 11. Xóa session mua hàng nhanh nếu còn
                Session.Remove("GioHangMuaNhanh");

                // 12. Chuyển hướng đến trang xác nhận
                System.Diagnostics.Debug.WriteLine("Redirecting to OrderConfirmation");
                return RedirectToAction("OrderConfirmation");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR in ThanhToan POST: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");

                TempData["ErrorMessage"] = "Đã xảy ra lỗi khi đặt hàng: " + ex.Message;
                return RedirectToAction("ThanhToan");
            }
        }

        // Trang xác nhận đơn hàng
        public ActionResult OrderConfirmation()
        {
            try
            {
                if (TempData["OrderSuccess"] == null)
                {
                    System.Diagnostics.Debug.WriteLine("No order success flag - Redirecting to Index");
                    return RedirectToAction("Index");
                }

                // Lấy thông tin từ TempData
                ViewBag.OrderId = TempData["OrderId"];
                ViewBag.TotalAmount = TempData["TotalAmount"];
                ViewBag.CustomerName = TempData["CustomerName"];
                ViewBag.CustomerPhone = TempData["CustomerPhone"];
                ViewBag.CustomerEmail = TempData["CustomerEmail"];
                ViewBag.CustomerAddress = TempData["CustomerAddress"];
                ViewBag.PaymentMethod = TempData["PaymentMethod"];
                ViewBag.OrderDate = TempData["OrderDate"];
                ViewBag.ItemCount = TempData["ItemCount"];
                ViewBag.SaveToDatabase = TempData["SaveToDatabase"];

                System.Diagnostics.Debug.WriteLine($"OrderConfirmation - Order ID: {ViewBag.OrderId}");

                return View();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR in OrderConfirmation: {ex.Message}");
                TempData["ErrorMessage"] = "Lỗi hiển thị xác nhận đơn hàng";
                return RedirectToAction("Index");
            }
        }

        // Mua hàng nhanh (chỉ mua 1 sản phẩm từ giỏ hàng)
        public ActionResult MuaHangNhanh(string id, int soLuong = 1)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"=== MuaHangNhanh: {id}, Quantity: {soLuong} ===");

                // 1. Kiểm tra đăng nhập
                if (Session["User"] == null)
                {
                    TempData["ReturnUrl"] = Url.Action("MuaHangNhanh", "Home", new { id, soLuong });
                    return RedirectToAction("Login");
                }

                // 2. Kiểm tra sản phẩm có tồn tại không
                var sanPham = db.SANPHAMs.Find(id);
                if (sanPham == null)
                {
                    TempData["ErrorMessage"] = "Sản phẩm không tồn tại!";
                    return RedirectToAction("GioHang");
                }

                // 3. Kiểm tra số lượng
                if (soLuong < 1) soLuong = 1;

                // 4. Tạo giỏ hàng mới chỉ chứa sản phẩm này
                var gioHangMoi = new List<ItemGioHang>
        {
            new ItemGioHang(id, soLuong)
        };

                // 5. Kiểm tra xem sản phẩm có được tạo thành công không
                if (gioHangMoi[0].TenSP == null)
                {
                    TempData["ErrorMessage"] = "Không thể lấy thông tin sản phẩm!";
                    return RedirectToAction("GioHang");
                }

                // 6. Lưu vào Session riêng cho mua hàng nhanh
                Session["GioHangMuaNhanh"] = gioHangMoi;

                System.Diagnostics.Debug.WriteLine($"Quick buy created for product: {gioHangMoi[0].TenSP}");

                // 7. Chuyển đến trang thanh toán
                return RedirectToAction("ThanhToan");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR in MuaHangNhanh: {ex.Message}");
                TempData["ErrorMessage"] = "Lỗi mua hàng nhanh: " + ex.Message;
                return RedirectToAction("GioHang");
            }
        }

        // ===============================
        // HÀM HỖ TRỢ
        // ===============================

        // Tạo mã đơn hàng
        private string GenerateOrderId()
        {
            string prefix = "DH";
            string datePart = DateTime.Now.ToString("yyMMdd");
            string timePart = DateTime.Now.ToString("HHmmss");

            // Tạo số ngẫu nhiên để tránh trùng
            Random random = new Random();
            string randomPart = random.Next(100, 999).ToString();

            return $"{prefix}{datePart}{timePart}{randomPart}";
        }

        // Lưu đơn hàng vào database (tùy chọn - tùy vào cấu trúc database của bạn)
        private string SaveOrderToDatabase(string orderId, string username, List<ItemGioHang> cartItems,
                                          string customerName, string customerPhone, string customerEmail,
                                          string address, string city, string district, string ward,
                                          string note, string paymentMethod, decimal totalAmount)
        {
            try
            {
                return orderId;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SaveOrderToDatabase ERROR: {ex.Message}");
                throw; // Ném lỗi lên để xử lý ở trên
            }
        }

        // Mua hàng nhanh (chỉ mua 1 sản phẩm từ giỏ hàng)
       
    }
}