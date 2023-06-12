using Microsoft.Data.SqlClient;
using Syren.QuickCartDAL;
using Syren.QuickCartDAL.Models;

namespace Syren.QuickCartBL
{
    public class CartLogic
    {
        QuickCartRepository repository;
        public CartLogic()
        {
            repository = new QuickCartRepository();
        }
        public List<Category> GetAllCategoriesLogic()
        {
            List<Category> catList = null;
            try
            {
                catList = repository.GetCategories();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Some Error occures in BL "+ex.Message);
            }
            return catList;

        }
        public List<Product> GetAllProductsLogic()
        {
            List<Product> productList = null;
            try
            {
                productList = repository.GetAllProducts();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
            return productList;
        }
        public List<Product> GetProductByCategoryLogic(byte catID)
        {
            List<Product> prodList = null;
            try
            {
                prodList = repository.GetProductByCategory(catID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Some Error occures in BL " + ex.Message);
            }
            return prodList;

        }
        public Product FilterProductLogic(byte catID)
        {
            Product product = null;
            try
            {
                product = repository.FilterProducts(catID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Some Error occures in BL " + ex.Message);
            }
            return product;
        }
        public List<User> GetUsersLogic()
        {
            List<User> usersList = null;
            try
            {
                usersList = repository.GetUsers();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Some Error occures in BL " + ex.Message);
            }
            return usersList;
        }
        public bool AddCategoryLogic(string catName)
        {
            bool result = false;
            try
            {
                result = repository.AddCategory(catName);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some Error occures in BL " + e.Message);
            }
            return result;
        }
        public bool AddProductLogic(Product product)
        {

            bool result = false;
            try
            {
                result = repository.AddProduct(product);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in BL " + e.Message);
            }
            return result;
        }
        public bool RegisterUserLogic(string userPassword, string gender, string emailId, DateTime dateOfBirth, string address)
        {
            bool result = false;
            
            try
            {
                result = repository.RegisterUser(userPassword, gender, emailId, dateOfBirth, address);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in BL " + e.Message);
            }
            return result;
        }
        public bool UpdateCategoryLogic(Category catObj)
        {
            bool result = false;
            try
            {
                result = repository.UpdateCategory(catObj);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }
        public bool DeleteProductLogic(string productID)
        {
            bool result = false;
            
            try
            {
                result = repository.DeleteProduct(productID);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in BL " + e.Message);
            }
            return result;
        }
        public int UpdateProductLogic(string productID, decimal price)
        {
            int result = 0;
            try
            {
                 result = repository.UpdateProduct(productID, price);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in BL " + e.Message);
                result = -99;
            }
            return result;
        }
        public bool DeleteProductsUsingRemoveRangeLogic(string subString)
        {

            bool status = false;
            try
            {
                status = repository.DeleteProductsUsingRemoveRange(subString);
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in BL " + e.Message);
            }
            return status;

        }
        //public int AddNewCategoryLogic(string name, out byte catId)
        //{
        //    int result = -1;
        //    catId = 0;
        //    try
        //    {
        //        result = repository.AddCategoryUsingUSP(name, out catId);
        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine(e.Message);
        //        result = -99;
        //    }
        //    return result;
        //}
        public int AddNewCategoryLogic(Category catObj)
        {
            int result = -1;
            //catId = 0;
            try
            {
                result = repository.AddCategoryUsingUSP(catObj);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                result = -99;
            }
            return result;
        }
        //public int RegisterNewUserLogic(string userPassword, string gender, string emailId, DateTime dateOfBirth, string address)
        //{

        //    int returnResult = -1; // the return result from usp by def 0
        //    try
        //    {
        //        returnResult = repository.RegisterNewUser(userPassword, gender, emailId, dateOfBirth, address);
        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine(e.Message);
        //    }

        //    return returnResult;
        //}
        public int RegisterNewUserLogic(User user)
        {

            int returnResult = -1; // the return result from usp by def 0
            try
            {
                returnResult = repository.RegisterNewUser(user);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            return returnResult;
        }
    }
}