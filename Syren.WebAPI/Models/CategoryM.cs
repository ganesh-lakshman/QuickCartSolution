using System.ComponentModel.DataAnnotations;

namespace Syren.WebAPI.Models
{
    public class CategoryM
    {
        public byte CategoryId { get; set; }
        [Required]
        [MaxLength(10), MinLength(5)]
        
        public string CategoryName { get; set; } = null!;
    }
}
