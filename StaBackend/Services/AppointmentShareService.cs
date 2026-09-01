using System.Text.Json;
using Microsoft.AspNetCore.DataProtection;
using StaBackend.Models;

namespace StaBackend.Services;

public class AppointmentShareService
    : IAppointmentShareService
{
    private readonly ITimeLimitedDataProtector _protector;

    public AppointmentShareService(
        IDataProtectionProvider dataProtectionProvider)
    {
        _protector = dataProtectionProvider
            .CreateProtector("STA.Appointment.Share.v1")
            .ToTimeLimitedDataProtector();
    }

    public string CreateToken(
        AppointmentShareInfo appointment,
        TimeSpan lifetime)
    {
        var json = JsonSerializer.Serialize(
            appointment
        );

        return _protector.Protect(
            json,
            lifetime
        );
    }

    public AppointmentShareInfo? ReadToken(
        string token)
    {
        try
        {
            var json =
                _protector.Unprotect(token);

            return JsonSerializer.Deserialize<
                AppointmentShareInfo
            >(json);
        }
        catch
        {
            // Token invalide, modifié ou expiré.
            return null;
        }
    }
}