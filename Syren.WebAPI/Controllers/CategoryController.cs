using Microsoft.AspNetCore.Mvc;
using Syren.QuickCartBL;
using Syren.QuickCartDAL.Models;
using Syren.WebAPI.Models;

namespace Syren.WebAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CategoryController : Controller
    {
        CartLogic cartLogic;
        public CategoryController() 
        {
            cartLogic = new CartLogic();
        }
        // action that is exposed to client
        [HttpGet]
        public JsonResult FetchAllCategories()
        {
            List<Category> catList=null;
            try
            {
                catList = cartLogic.GetAllCategoriesLogic();
            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in FetchALlCategories(): " + ex.Message);

            }
            return Json(catList);
        }
        // we are giving data in url
        //[HttpGet]
        //public int AddCategory(string catName)
        //{
        //    int result=-1;
        //    byte catId;
        //    try
        //    {
        //        result = cartLogic.AddNewCategoryLogic(catName, out catId);

        //    }
        //    catch (Exception ex)
        //    {
        //        System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in AddCategory(string catName): " + ex.Message);

        //    }
        //    return result;
        //}
        // in post, put, delete the data will be sent in the body
        //{

        //  "categoryid": 2,
        //  "categoryname": "aaaaaab"

        //}
    [HttpPost]
        public int AddCategory(CategoryM catObj)
        {
            int result = -1;
            try
            {
                if(ModelState.IsValid)
                {
                    Category category = new Category();
                    category.CategoryName = catObj.CategoryName;
                    category.CategoryId = catObj.CategoryId;
                    result = cartLogic.AddNewCategoryLogic(category);
                }
                else
                {
                    result = -99;
                }

            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in AddCategory(string catName): " + ex.Message);

            }
            return result;
        }
        [HttpPut]
        public bool UpdateCategory(CategoryM catObj)
        {
            bool result = false;
            try
            {
                if(ModelState.IsValid)
                {
                    Category category = new Category();
                    category.CategoryName= catObj.CategoryName;
                    category.CategoryId= catObj.CategoryId;
                    result = cartLogic.UpdateCategoryLogic(category);
                }
            }
            catch (Exception ex)
            {

            }
            return result;
        }
        
    }

}
