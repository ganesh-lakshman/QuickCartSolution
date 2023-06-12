using Syren.QuickCartBL;
using Syren.QuickCartDAL.Models;

class Program
{
    public static void GetAllCategories()
    {
        List<Category> catList;
        CartLogic _logic  = new CartLogic();
        try
        {
            catList = _logic.GetAllCategoriesLogic();
            foreach(var item in catList)
            {
                Console.WriteLine("{0} \t {1}", item.CategoryId, item.CategoryName);
            }
                
        }
        catch(Exception ex) 
        {
            Console.WriteLine("Some error in console "+ex.Message);
        }
       
    }
    public static void GetAllProducts()
    {
        List<Product> prodList;
        CartLogic _logic = new CartLogic();
        try
        {
            prodList = _logic.GetProductByCategoryLogic(1);
            foreach (var item in prodList)
            {
                Console.WriteLine("{0} \t {1} \t {2}", item.ProductId, item.ProductName, item.Price);
            }

        }
        catch (Exception ex)
        {
            Console.WriteLine("Some error in console " + ex.Message);
        }

    }
    public static void FilterProducts(byte categoryID)
    {
        Product product = null;
        CartLogic _logic = new CartLogic();
        try
        {
            product = _logic.FilterProductLogic(categoryID);
            Console.WriteLine("{0} \t {1} \t {2}", product.ProductId, product.ProductName, product.Price);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Some error in console " + ex.Message);
        }

    }
    public static void GetUsers()
    {
        List<User> users = null;
        CartLogic _logic = new CartLogic();
        try
        {
            users = _logic.GetUsersLogic();
            foreach (var user in users)
            {
                Console.WriteLine("{0} \t {1} \t {2} \t {3}",user.EmailId, user.Gender, user.DateOfBirth, user.Address);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Some error in console " + ex.Message);
        }
    }
    public static bool AddCategory(string catName)
    {
        CartLogic _logic = new CartLogic();
        bool result = false;
        try
        {
            result = _logic.AddCategoryLogic(catName);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error in console " + e.Message);
        }
        return result;
    }
    public static bool AddProduct(string productID, string productName, byte categoryId, decimal price, int qa)
    {
        CartLogic _logic = new CartLogic();
        bool result = false;
        try
        {
            result = _logic.AddProductLogic(productID, productName, categoryId, price, qa);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error occured in BL " + e.Message);
        }
        return result;
    }
    public static bool RegisterUser(string userPassword, string gender, string emailId, DateTime dateOfBirth, string address)
    {
        bool result = false;
        CartLogic _logic = new CartLogic();
        try
        {
            result = _logic.RegisterUserLogic(userPassword, gender, emailId, dateOfBirth, address);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error occured in BL " + e.Message);
        }
        return result;
    }
    public static bool UpdateCategory(byte categoryID, string newCategoryName)
    {
        bool result = false;
        CartLogic _logic = new CartLogic();
        try
        {
            result = _logic.UpdateCategoryLogic(categoryID, newCategoryName);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error occured in DAL " + e.Message);
        }
        return result;
    }
    public static bool DeleteProduct(string productID)
    {
        bool result = false;
        CartLogic _logic = new CartLogic();
        try
        {
            result = _logic.DeleteProductLogic(productID);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error occured in console " + e.Message);
        }
        return result;
    }
    public static int UpdateProduct(string productID, decimal price)
    {
        int result = 0;
        CartLogic _logic = new CartLogic();
        try
        {
            result = _logic.UpdateProductLogic(productID, price);
        }
        catch (Exception e)
        {
            Console.WriteLine("Some error occured in console " + e.Message);
            result = -99;
        }
        return result;
    }
    public static bool DeleteProductsUsingRemoveRange(string subString)
    {
        CartLogic _logic = new CartLogic();
        bool status = false;
        try
        {
            status = _logic.DeleteProductsUsingRemoveRangeLogic(subString);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
        return status;

    }
    public static int AddNewCategory()
    {
        int result = -1;
        try
        {
            CartLogic _logic = new CartLogic();
            result = _logic.AddNewCategoryLogic("Pens", out byte catId);
            Console.WriteLine("result/status: "+result);
            Console.WriteLine("catid: "+catId);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
            result = -99;
        }
        return result;
    }
    public static int RegisterNewUser()
    {

        int returnResult = -1; // the return result from usp by def 0
        try
        {
            CartLogic _logic = new CartLogic();
            returnResult = _logic.RegisterNewUserLogic("GANES@1234", "M", "ganes@gmail.com", new DateTime(2000, 10, 08), "7-130 ppm");
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }

        return returnResult;
    }
    public static void Main()
    {
        //GetAllCategories();
        //GetAllProducts();
        //FilterProducts(15);
        //GetUsers();
        //Console.WriteLine(UpdateCategory(8, "paints"));
        //Console.WriteLine(AddCategory("Paint"));
        //Console.WriteLine(AddProduct("P158", "Asian Points", 8, 500, 10));
        //Console.WriteLine(RegisterUser("GANES@1234", "M", "ganesh@gmail.com",new DateTime(2000, 10, 08), "7-130 ppm"));
        //Console.WriteLine(DeleteProduct("P102")); // we cannot delete somethinf that is referncing in productdetails table, check proddetails tyable and the delete

        //Console.WriteLine(UpdateProduct("P103", 799));
        //Console.WriteLine(DeleteProductsUsingRemoveRange("Asian"));
        //AddNewCategory();
        Console.WriteLine(RegisterNewUser());
        
    }
}