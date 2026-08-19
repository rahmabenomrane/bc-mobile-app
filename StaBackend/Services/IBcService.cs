using StaBackend.Models;
namespace StaBackend.Services
{
    public interface IBcService
    {

        Task<LoginResponse> LoginAsync(string phone, string password);
        Task LogoutAsync(string token);
        Task<RegisterResponse> RegisterAsync(RegisterRequest request);
        Task<List<VehicleDto>> GetCustomerVehiclesAsync(string customerNum);
        Task<CustomerInfo?> GetCustomerByNumberAsync(string customerNumber);
        Task<UpdateProfileResponse> UpdateCustomerProfileAsync(string customerNumber, UpdateProfileRequest request);
        Task<bool> IsPhoneUniqueAsync(string phone, string currentCustomerNumber);
        Task<bool> IsEmailUniqueAsync(string email, string currentCustomerNumber);
        Task<List<AgencyDto>> GetAgenciesAsync();
        Task<List<AppointmentDto>> GetAppointmentsAsync(string agencyCode, string serviceCode);
        Task<CreateAppointmentResponse> CreateAppointmentAsync(CreateAppointmentDto dto);
        Task<List<AppointmentDto>> GetCustomerAppointmentsAsync(string customerNumber);
        Task<bool> RescheduleAppointmentAsync(RescheduleAppointmentDto dto);
        Task<string?> GetCustomerEmailAsync(string customerNumber);
        Task ConfirmAppointmentAsync(string appointmentNo);
        Task<List<CarLiftDto>> GetCarLiftsAsync(string agencyCode);
        Task<List<AppointmentDto>> GetAllAppointmentsForAgencyAsync(string agencyCode);
        Task CancelAppointmentAsync(string appointmentNo);

        Task<bool> CreateVehicleAsync(CreateVehicleDto vehicle);
        Task<List<ClaimInfo>> GetClaimsAsync(string customerNumber);
        Task<CreateClaimResponse> CreateClaimAsync(CreateClaimRequest request);
        Task UpdateClaimStatusAsync(int claimNumber, int newStatus);
        Task<List<MakeDto>> GetMakesAsync();
        Task<List<ModelDto>> GetModelsByMakeAsync(string makeCode);
        Task<List<NonworkingDayDto>> GetAgencyNonworkingDaysAsync(string agencyCode, DateTime from, DateTime to);
        Task<List<AppointmentDto>> GetAppointmentsByDateAsync(DateTime date);
        Task<List<ServiceDto>> GetServicesByAgencyAsync(string agencyCode);
        Task<VehicleDto?> GetVehicleByNumAsync(string numVehicle);
        Task<List<BCAgencyService>> GetAgenciesByServiceAsync(string serviceType);
        Task<List<BCAgencyService>> GetAgenciesByServiceCodeAsync(
    string serviceCode
);
        Task<List<BCServiceModel>> GetAllServicesAsync();
        Task<UpdateProfileResponse> ChangePasswordAsync(string customerNumber, string currentPassword, string newPassword);
    }
}