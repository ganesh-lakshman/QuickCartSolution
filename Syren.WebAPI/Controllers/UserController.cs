using Microsoft.AspNetCore.Mvc;
using Syren.QuickCartBL;
using Syren.QuickCartDAL.Models;
using Syren.WebAPI.Models;

namespace Syren.WebAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class UserController : Controller
    {
        CartLogic cartLogic;
        public UserController()
        {
            cartLogic = new CartLogic();
        }
        [HttpPost]
        public int AddUser(UserM user)
        {
            int result = -1;
            try
            {
                if (ModelState.IsValid)
                {
                    User u = new User();
                    u.Address = user.Address;
                    u.UserPassword = user.UserPassword;
                    u.DateOfBirth = user.DateOfBirth;
                    u.EmailId = user.EmailId;
                    u.RoleId = user.RoleId;
                    u.Role = user.Role;
                    u.Gender = user.Gender;

                    result = cartLogic.RegisterNewUserLogic(u);
                }
                else
                {
                    result = -99;
                }
            }
            catch (Exception ex)
            {
                //System.IO.File.AppendAllText("C:\\Users\\SYR00398\\source\\repos\\stepTrack.txt", "Exception in AddUser: " + ex.Message);
            }
            return result;
        }
    }
}
