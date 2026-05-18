namespace StaBackend.Models
{
    public class RegisterRequest
    {
        public string Phone { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;   
        public string Address { get; set; } = string.Empty;   
        public string Civility { get; set; } = "Monsieur";    
    }

    public class RegisterResponse
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
    }
}