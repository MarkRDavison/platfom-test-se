using System;
using System.ComponentModel.DataAnnotations;

namespace DotNetCoreSqlDb.Models
{
    public class Profile
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }
        public string Country { get; set; }
        public string Comment { get; set; }
    }
}

