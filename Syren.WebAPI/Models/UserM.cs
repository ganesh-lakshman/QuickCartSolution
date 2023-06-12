using Syren.QuickCartDAL.Models;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Syren.WebAPI.Models
{
    public class UserM
    {
        [Required]
        [EmailAddress]
        [RegularExpression("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")]
        public string EmailId { get; set; } = null!;
        [Required]
        [PasswordPropertyText]
        [RegularExpression(@"((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W]).{6,20})")]
        public string UserPassword { get; set; } = null!;

        public byte? RoleId { get; set; }
        [RegularExpression("^(M|F)$")]
        public string Gender { get; set; } = null!;
        [DataType(DataType.Date)]
        public DateTime DateOfBirth { get; set; }

        public string Address { get; set; } = null!;

        public virtual ICollection<PurchaseDetail> PurchaseDetails { get; set; } = new List<PurchaseDetail>();

        public virtual Role? Role { get; set; }
    }
}
