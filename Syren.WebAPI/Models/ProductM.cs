using Syren.QuickCartDAL.Models;
using System.ComponentModel.DataAnnotations;


namespace Syren.WebAPI.Models
{
    public class ProductM
    {
        [Required]
        [StringLength(4)]
        [RegularExpression("^P.*")]
        public string ProductId { get; set; } = null!;
        [Required]
        [MinLength(5), MaxLength(30)]
        public string ProductName { get; set; } = null!;

        public byte? CategoryId { get; set; }

        [Required]
        [Range(1, double.MaxValue)]
        public decimal Price { get; set; }
        [Required]
        [Range(1, double.MaxValue)]
        public int QuantityAvailable { get; set; }

        public virtual Category? Category { get; set; }

        public virtual ICollection<PurchaseDetail> PurchaseDetails { get; set; } = new List<PurchaseDetail>();
    }
}
