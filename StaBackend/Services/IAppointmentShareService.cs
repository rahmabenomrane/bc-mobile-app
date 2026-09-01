using StaBackend.Models;

namespace StaBackend.Services;

public interface IAppointmentShareService
{
    string CreateToken(
        AppointmentShareInfo appointment,
        TimeSpan lifetime
    );

    AppointmentShareInfo? ReadToken(
        string token
    );
}