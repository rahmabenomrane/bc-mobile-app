using StaBackend.Models;

namespace StaBackend.Services;

public interface IAppointmentPdfService
{
    byte[] Generate(
        AppointmentShareInfo appointment
    );
}