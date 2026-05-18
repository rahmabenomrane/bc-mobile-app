using StaBackend.Models;

namespace StaBackend.Services
{
    public interface IBcService
    {
        // Plus besoin de GetAzureTokenAsync() !
        Task<LoginResponse> LoginAsync(string phone, string password);
        Task LogoutAsync(string token);
        Task<RegisterResponse> RegisterAsync(RegisterRequest request);
        Task<List<VehicleDto>> GetCustomerVehiclesAsync(string customerNum);
        // Nouvelles méthodes pour le profil
        Task<CustomerInfo?> GetCustomerByNumberAsync(string customerNumber);
        Task<UpdateProfileResponse> UpdateCustomerProfileAsync(string customerNumber, UpdateProfileRequest request);
        Task<bool> IsPhoneUniqueAsync(string phone, string currentCustomerNumber);
        Task<bool> IsEmailUniqueAsync(string email, string currentCustomerNumber);
    }
}