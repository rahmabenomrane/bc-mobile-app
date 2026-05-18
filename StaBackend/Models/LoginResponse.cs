
namespace StaBackend.Models
{
    public class LoginResponse
    {
        public bool Success { get; set; }
        public string Token { get; set; } = string.Empty;
        public string ExpiresAt { get; set; } = string.Empty;
        public string? CustomerNumber { get; set; }
        public string? Error { get; set; } 
    }
}