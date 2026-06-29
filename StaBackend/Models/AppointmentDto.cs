public class AppointmentDto
{
    public string AgencyCode { get; set; }
    public string AgencyName { get; set; }
    public string ServiceCode { get; set; }
    public string ServiceDescription { get; set; }
    public DateTime Date { get; set; }
    public string PontId { get; set; }
    public string Status { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public string AppointmentNo { get; set; }
    public string NumVehicle { get; set; }
    public string? RegistrationNumber { get; set; }

    public float? Mileage { get; set; }
}