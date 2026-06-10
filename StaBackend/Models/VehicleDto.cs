
namespace StaBackend.Models
{
    public class VehicleDto
    {
        public string Id { get; set; } = string.Empty;
        public string NumVehicle { get; set; } = string.Empty;
        public string NumCustomer { get; set; } = string.Empty;
        public string MakeCode { get; set; } = string.Empty;
        public string ModelCode { get; set; } = string.Empty;
        public string Motorisation { get; set; } = string.Empty;
        public string? RegistrationNumber { get; set; }
        public float Mileage { get; set; }
    }
    public class CreateVehicleDto
    {
        public string NumCustomer { get; set; } = string.Empty;
        public string MakeCode { get; set; } = string.Empty;
        public string ModelCode { get; set; } = string.Empty;
        public string Motorisation { get; set; } = string.Empty;
        public string RegistrationNumber { get; set; } = string.Empty;
        public int Mileage { get; set; } = 0;
    }
}