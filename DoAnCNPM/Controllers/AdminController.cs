using DoAnCNPM.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAnCNPM.Controllers
{
    public class AdminController : Controller
    {
        // Khai báo DbContext
        QL_SIEUTHIMINI_TIEMTAPHOAEntities1 db = new QL_SIEUTHIMINI_TIEMTAPHOAEntities1();

        // Phương thức kiểm tra quyền truy cập Admin
        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Nếu Session Admin bị mất (chưa đăng nhập hoặc session hết hạn)
            if (Session["Role"] == null || Session["Role"].ToString() != "ADMIN")
            {
                // SỬA LỖI TẠI ĐÂY: Dùng RouteData để lấy tên Action và Controller
                TempData["ReturnUrl"] = Url.Action(
                    (string)filterContext.RouteData.Values["action"], // Lấy tên Action
                    (string)filterContext.RouteData.Values["controller"], // Lấy tên Controller
                    filterContext.RouteData.Values // Truyền các tham số khác
                );

                // Chuyển hướng về trang đăng nhập
                filterContext.Result = RedirectToAction("Login", "Home");
                return;
            }
            base.OnActionExecuting(filterContext);
        }

        // GET: Admin/Index (Trang chủ Admin Dashboard)
        public ActionResult Index()
        {
            // Hiển thị tổng quan hệ thống (ví dụ: số đơn hàng mới, số người dùng,...)
            ViewBag.TotalProducts = db.SANPHAMs.Count();
        
            ViewBag.TotalUsers = db.TAIKHOANs.Count();

            return View();
        }

        // ==================================================
        // CHỨC NĂNG QUẢN LÝ SẢN PHẨM (MẪU CRUD)
        // ==================================================

        // GET: Admin/ProductList (Danh sách Sản phẩm)
        public ActionResult ProductList()
        {
            var productList = db.SANPHAMs.ToList();
            return View(productList);
        }

        // Ví dụ: GET: Admin/DeleteProduct/MASP (Xóa sản phẩm)
        public ActionResult DeleteProduct(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return HttpNotFound();
            }

            var product = db.SANPHAMs.SingleOrDefault(sp => sp.MASP == id);

            if (product == null)
            {
                return HttpNotFound();
            }

            // Có thể thêm bước xác nhận trước khi xóa
            try
            {
                db.SANPHAMs.Remove(product);
                db.SaveChanges();
                TempData["SuccessMessage"] = "Đã xóa sản phẩm thành công.";
            }
            catch (Exception)
            {
                TempData["ErrorMessage"] = "Không thể xóa sản phẩm này do ràng buộc khóa ngoại (Có trong đơn hàng).";
            }

            return RedirectToAction("ProductList");
        }



        // Trong file AdminController.cs

        // ... (Các Action ProductList và DeleteProduct ở trên) ...

        // ==================================================
        // THÊM SẢN PHẨM MỚI (CREATE)
        // ==================================================

        // GET: Admin/CreateProduct (Hiển thị form Thêm mới)
        public ActionResult CreateProduct()
        {
            // Lấy danh sách Loại sản phẩm để đổ vào DropdownList
            ViewBag.MALOAI = new SelectList(db.LOAISANPHAMs, "MALOAI", "TENLOAI");
            return View();
        }

        // POST: Admin/CreateProduct (Xử lý lưu sản phẩm vào DB)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateProduct(SANPHAM newProduct, HttpPostedFileBase ImageFile)
        {
            // Lấy lại danh sách Loại sản phẩm (cần thiết nếu có lỗi)
            ViewBag.MALOAI = new SelectList(db.LOAISANPHAMs, "MALOAI", "TENLOAI", newProduct.MALOAI);

            // 1. Kiểm tra ảnh sản phẩm
            if (ImageFile == null || ImageFile.ContentLength == 0)
            {
                ModelState.AddModelError("HINHANH", "Vui lòng chọn ảnh đại diện cho sản phẩm.");
            }
            else
            {
                // 2. Xử lý ảnh
                try
                {
                    string fileName = System.IO.Path.GetFileName(ImageFile.FileName);
                    // Tạo tên file duy nhất để tránh trùng lặp
                    string path = System.IO.Path.Combine(Server.MapPath("~/Content/Images/"), DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + fileName);
                    ImageFile.SaveAs(path);

                    //// Chỉ lưu tên file/đường dẫn tương đối vào database
                    //newProduct.HINH = "~/Images/" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + fileName;


                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("", "Lỗi khi lưu ảnh: " + ex.Message);
                }
            }

            // 3. Kiểm tra Model (bao gồm các trường required khác)
            if (ModelState.IsValid)
            {
                // Thêm sản phẩm vào DB
                db.SANPHAMs.Add(newProduct);
                db.SaveChanges();
                TempData["SuccessMessage"] = "Đã thêm sản phẩm mới thành công!";
                return RedirectToAction("ProductList");
            }

            // Nếu Model không hợp lệ hoặc lỗi ảnh, quay lại View
            return View(newProduct);
        }
    }
}