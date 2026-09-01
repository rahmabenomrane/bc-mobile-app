namespace StaBackend.Models;

public class AppointmentShareResponse
{
    public string ShareUrl { get; set; } = "";

    public DateTime ExpiresAt { get; set; }
}