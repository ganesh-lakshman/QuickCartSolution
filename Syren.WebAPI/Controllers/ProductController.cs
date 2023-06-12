using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Query.Internal;
using Syren.QuickCartBL;
using Syren.QuickCartDAL.Models;
using Syren.WebAPI.Models;

namespace Syren.WebAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class ProductController : Controller
    {
        CartLogic cartLogic;
        public ProductController()
        {
            cartLogic = new CartLogic();
        }
        // action that is exposed to client
        [HttpGet]
        public JsonResult FilterProducts(Byte catId)
        {
            Product product = null;
            try
            {
                product = cartLogic.FilterProductLogic(catId);
            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in FilterProducts(): " + ex.Message);
            }
            return Json(product);
        }
        [HttpGet]
        public JsonResult ListProducts()
        {
            List<Product> products = null;
            try
            {
                products = cartLogic.GetAllProductsLogic();
            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in ListProducts(): " + ex.Message);
            }
            return Json(products);
        }
        [HttpPost]
        //{

        //  "ProductId": "P158",
        //  "ProductName": "bike",
        //  "CategoryId": "1",
        //  "Price": "5000",
        //  "QuantityAvailable": "10"

        //}
    public bool AddProduct(ProductM product)
        {
            bool result = false;
            try
            {
                if (ModelState.IsValid)
                {
                    Product product1 = new Product();
                    product1.ProductId = product.ProductId;
                    product1.CategoryId = product.CategoryId;
                    product1.ProductName = product.ProductName;
                    product1.QuantityAvailable = product.QuantityAvailable;
                    product1.Price = product.Price;

                    result = cartLogic.AddProductLogic(product1);
                }
                else
                {
                    result = false;
                }
            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in AddProduct(Product product): " + ex.Message);
            }
            return result;
        }
        [HttpDelete]
        public bool DeleteProduct(string productId)
        {
            bool result = false;
            try
            {
                result = cartLogic.DeleteProductLogic(productId);
            }
            catch
            {

            }
            return result;
        }
    }
}
