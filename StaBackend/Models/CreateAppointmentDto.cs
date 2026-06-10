public class CreateAppointmentDto
{
    public string AgencyCode { get; set; }
    public string ServiceCode { get; set; }
    public DateTime Date { get; set; }
    public string VehicleNumber { get; set; }
    public string PontId { get; set; }
    public int StartTime { get; set; }
    public int EndTime { get; set; }
    public string CustomerNumber { get; set; }
}