using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query.Internal;
using Syren.QuickCartDAL.Models;
using System;

namespace Syren.QuickCartDAL
{
    public class QuickCartRepository
    {
        SyrenDbContext context; // created an instance variable context of type SyrenDbContext


        public QuickCartRepository()
        {
            context = new SyrenDbContext();
        }
        // fetch all the details of the categories table in the DAL
        //public List<Category> GetCategories()
        //{
        //    List<Category> catList = null;
        //    try
        //    {
        //        catList = (from c in context.Categories
        //                   orderby c.CategoryId
        //                   select c
        //                 ).ToList();
        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine("Some error occured in DAL "+e.Message);
        //    }
        //    return catList;
        //}
        public List<Category> GetCategories()
        {
            List<Category> catList = null;
            try
            {
                catList = context.Categories.FromSql($"select * from categories").ToList();
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            //return catList;
            return null;
        }
        public List<Product> GetAllProducts() 
        {
            List<Product> productList = null;
            try
            {
                productList = (from p in context.Products
                               select p
                               ).ToList();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
            return productList;
        }
        public List<Product> GetProductByCategory(byte catID)
        {
            List<Product> productList = null;

            try
            {
                productList = (from p in context.Products
                               where p.CategoryId == catID
                               select p).ToList();
            }
            catch(Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return productList;
        }
        public Product FilterProducts(byte catID)
        {
            Product product = null;
            try
            {
                List<Product> productList = GetProductByCategory(catID);
                product = productList.FirstOrDefault();
                //product = (from p in context.Products
                //           where p.CategoryId == catID
                //           select p).First();
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return product;
        }
        public List<User> GetUsers()
        {
            List<User> users = null;
            try
            {
                users = (from u in context.Users
                         select u
                         ).ToList();
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return users;
        }

        // Adding a new category in Category Table

        public bool AddCategory(string catName)
        {
            Category category = new Category();
            category.CategoryName = catName;
            bool result = false;
            try
            {
                context.Add(category);
                context.SaveChanges();
                result = true;
            }
            catch (Exception e) 
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }
        //public bool AddProduct(string productID, string productName, byte categoryId, decimal price, int qa)
        //{
        //    Product product = new Product();
        //    product.ProductId = productID;
        //    product.ProductName = productName;
        //    product.CategoryId = categoryId;
        //    product.Price = price;
        //    product.QuantityAvailable = qa;
        //    bool result = false;
        //    try
        //    {
        //        context.Add(product);
        //        context.SaveChanges(); result = true;
        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine("Some error occured in DAL " + e.Message);
        //    }
        //    return result;
        //}
        public bool AddProduct(Product prod)
        {
            Product product = new Product();
            product.ProductId = prod.ProductId;
            product.ProductName = prod.ProductName;
            product.CategoryId = prod.CategoryId;
            product.Price = prod.Price;
            product.QuantityAvailable = prod.QuantityAvailable;
            bool result = false;
            try
            {
                context.Add(prod);
                context.SaveChanges(); result = true;
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }
        public bool RegisterUser(string userPassword, string gender, string emailId, DateTime dateOfBirth, string address)
        {
            bool result = false;
            User user = new User();
            user.Address = address;
            user.Gender = gender;
            user.EmailId = emailId;
            user.UserPassword = userPassword;
            user.DateOfBirth = dateOfBirth;
            try
            {
                context.Add(user);
                context.SaveChanges(); result = true;
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }
        public bool UpdateCategory(Category catObj)
        {
            bool result = false;
            try
            {
                Category category = (from c in context.Categories
                                     where c.CategoryId == catObj.CategoryId
                                     select c).First();
                if(category != null)
                {
                    category.CategoryName = catObj.CategoryName;
                    context.SaveChanges(); result = true;
                }

            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }
        public bool UpdateUserPassword(string emailId, string newUserPassword)
        {
            bool result = false;
            try
            {
                User user = (from u in context.Users
                             where u.EmailId == emailId
                             select u
                             ).First();
                user.UserPassword = newUserPassword;
                context.SaveChanges(); result = true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
            return result;
        }
        public bool DeleteProductsUsingRemoveRange(string subString)
        {

            bool status = false;
            try
            {
                List<Product> products = (from p in context.Products
                                          where p.ProductName.Contains(subString)
                                          select p).ToList();
                //foreach (var item in products)
                //{
                //    Console.WriteLine("{0}", item.ProductName);
                //}
                context.RemoveRange(products);
                context.SaveChanges(); status = true;
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return status;

        }
        public bool DeleteUserDetails(string emailID)
        {
            bool result = false;
            User tempUserObj = null;
            try
            {
                tempUserObj = (from c in context.Users
                               where c.EmailId == emailID
                               select c).First();
                if (tempUserObj != null)
                {
                    context.Users.Remove(tempUserObj);
                    context.SaveChanges();
                    result = true;
                }
                else
                {
                    Console.WriteLine("user not exists");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Some error occured in DAL.." + ex.Message);
            }
            return result;
        }
        public int UpdateProduct(string  productID, decimal price)
        {
            int result = 0;
            try
            {
                Product product = (from c in context.Products
                                   where c.ProductId==productID
                                   select c
                                   ).First();
                if (product != null)
                {
                    product.Price = price;
                    context.SaveChanges();
                    result = 1;
                }
                else
                {
                    result = 0;
                }
            }
            catch (Exception e) 
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
                result = -99;
            }
            return result;
        }
        public bool DeleteProduct(string productID)
        {
            bool result = false;
            Product p = null;
            try
            {
                p = (from pd in context.Products
                     where pd.ProductId == productID
                     select pd).First();
                if(p != null)
                {
                    context.Products.Remove(p);
                    context.SaveChanges(); result = true;
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Some error occured in DAL " + e.Message);
            }
            return result;
        }


        //public int AddCategoryUsingUSP(string categoryName, out byte catId)
        //{
        //    catId = 0; //output param
        //    int result = -1; // number of rows effected
        //    int returnResult = -1; //return value received from proc

        //    try
        //    {
        //        // forming of input parameter
        //        SqlParameter prmCategoryName = new SqlParameter("@CategoryName", categoryName);

        //        // forming of output parameter
        //        SqlParameter prmCategoryID = new SqlParameter("@CategoryId", System.Data.SqlDbType.TinyInt);
        //        prmCategoryID.Direction = System.Data.ParameterDirection.Output;

        //        // forming of return value

        //        SqlParameter prmReturnResult = new SqlParameter("@retValue", System.Data.SqlDbType.Int);
        //        prmReturnResult.Direction = System.Data.ParameterDirection.Output;

        //        result = context.Database.ExecuteSqlRaw("exec @retValue=usp_AddCategory @CategoryName, @CategoryId out", new[] {prmReturnResult, prmCategoryName, prmCategoryID});
        //        Console.WriteLine("num of rows effected " + result);
        //        returnResult = Convert.ToInt32(prmReturnResult.Value);
        //        if(returnResult > 0)
        //        {
        //            catId = Convert.ToByte(prmCategoryID.Value);
        //        }

        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine(e.Message);
        //    }

        //    return returnResult;
        //}

        public int AddCategoryUsingUSP(Category catObj)
        {
            //catId = 0; //output param
            int result = -1; // number of rows effected
            int returnResult = -1; //return value received from proc

            try
            {
                // forming of input parameter
                SqlParameter prmCategoryName = new SqlParameter("@CategoryName", catObj.CategoryName);
                

                // forming of output parameter
                SqlParameter prmCategoryID = new SqlParameter("@CategoryId", System.Data.SqlDbType.TinyInt);
                prmCategoryID.Direction = System.Data.ParameterDirection.Output;

                // forming of return value

                SqlParameter prmReturnResult = new SqlParameter("@retValue", System.Data.SqlDbType.Int);
                prmReturnResult.Direction = System.Data.ParameterDirection.Output;

                result = context.Database.ExecuteSqlRaw("exec @retValue=usp_AddCategory @CategoryName, @CategoryId out", new[] { prmReturnResult, prmCategoryName, prmCategoryID });
                Console.WriteLine("num of rows effected " + result);
                returnResult = Convert.ToInt32(prmReturnResult.Value);
                //if (returnResult > 0)
                //{
                //    catId = Convert.ToByte(prmCategoryID.Value);
                //}

            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            return returnResult;
        }
        //public int RegisterNewUser(string userPassword, string gender, string emailId, DateTime dateOfBirth, string address)
        //{
        //    int result = -1; //num of rows effected
        //    int returnResult = -1; // the return result from usp by def 0
        //    try
        //    {
        //        // forming of input parameters
        //        SqlParameter prmUserPassword = new SqlParameter("@UserPassword", userPassword);
        //        SqlParameter prmGender = new SqlParameter("@Gender", gender);
        //        SqlParameter prmEmailId = new SqlParameter("@EmailId", emailId);
        //        SqlParameter prmDateOfBirth = new SqlParameter("@DateOfBirth", dateOfBirth);
        //        SqlParameter prmAddress = new SqlParameter("@Address", address);

        //        // forming of return value
        //        SqlParameter prmReturnResult = new SqlParameter("@retValue", System.Data.SqlDbType.Int);
        //        prmReturnResult.Direction = System.Data.ParameterDirection.Output;
        //        result = context.Database.ExecuteSqlRaw("exec @retValue=usp_RegisterUser @UserPassword, @Gender, @EmailId, @DateOfBirth, @Address", 
        //            new[] { prmReturnResult, prmUserPassword, prmGender, prmEmailId, prmDateOfBirth, prmAddress });

        //        Console.WriteLine("num of rows effected " + result);
        //        returnResult = Convert.ToInt32(prmReturnResult.Value);
        //    }
        //    catch (Exception e)
        //    {
        //        Console.WriteLine(e.Message);
        //    }

        //    return returnResult;
        //}
        public int RegisterNewUser(User user)
        {
            int result = -1; //num of rows effected
            int returnResult = -1; // the return result from usp by def 0
            try
            {
                // forming of input parameters
                SqlParameter prmUserPassword = new SqlParameter("@UserPassword", user.UserPassword);
                SqlParameter prmGender = new SqlParameter("@Gender", user.Gender);
                SqlParameter prmEmailId = new SqlParameter("@EmailId", user.EmailId);
                SqlParameter prmDateOfBirth = new SqlParameter("@DateOfBirth", user.DateOfBirth);
                SqlParameter prmAddress = new SqlParameter("@Address", user.Address);

                // forming of return value
                SqlParameter prmReturnResult = new SqlParameter("@retValue", System.Data.SqlDbType.Int);
                prmReturnResult.Direction = System.Data.ParameterDirection.Output;
                result = context.Database.ExecuteSqlRaw("exec @retValue=usp_RegisterUser @UserPassword, @Gender, @EmailId, @DateOfBirth, @Address",
                    new[] { prmReturnResult, prmUserPassword, prmGender, prmEmailId, prmDateOfBirth, prmAddress });

                Console.WriteLine("num of rows effected " + result);
                returnResult = Convert.ToInt32(prmReturnResult.Value);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            return returnResult;
        }









    }
    

    

}