public class CreateAppointmentResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public AppointmentDto Data { get; set; }
    public List<AppointmentDto> value { get; set; }
}