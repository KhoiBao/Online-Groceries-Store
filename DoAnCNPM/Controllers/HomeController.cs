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
            return View();
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

        public ActionResult admin()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult GioHang()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}