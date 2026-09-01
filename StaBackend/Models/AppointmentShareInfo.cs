namespace StaBackend.Models;

public class AppointmentShareInfo
{
    public string AppointmentNo { get; set; } = "";

    public string CustomerEmail { get; set; } = "";

    public string VehicleRegistration { get; set; } = "";

    public string VehicleName { get; set; } = "";

    public string AgencyName { get; set; } = "";

    public string AgencyAddress { get; set; } = "";

    public string AgencyPhone { get; set; } = "";

    public string ServiceName { get; set; } = "";

    public string AppointmentDate { get; set; } = "";

    public string AppointmentTime { get; set; } = "";

    public string Status { get; set; } = "Confirmé";
}