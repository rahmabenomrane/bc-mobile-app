// UpdateProfileRequest.cs
namespace StaBackend.Models
{
    public class UpdateProfileRequest
    {
        public string? LastName { get; set; }
        public string? FirstName { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public string? Civility { get; set; }
    }

    public class UpdateProfileResponse
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
    }

    // CustomerInfo.cs (pour GET profile)
    public class CustomerInfo
    {
        public string NumCustomer { get; set; } = "";
        public string Name { get; set; } = "";
        public string FirstName { get; set; } = "";
        public string Address { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Email { get; set; } = "";
        public string Civility { get; set; } = "";
    }
}