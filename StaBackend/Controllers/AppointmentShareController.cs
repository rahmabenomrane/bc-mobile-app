using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StaBackend.Models;
using StaBackend.Services;

namespace StaBackend.Controllers;

[ApiController]
[Route("api/appointment-share")]
public class AppointmentShareController
    : ControllerBase
{
    private readonly IAppointmentShareService
        _shareService;

    private readonly IAppointmentPdfService
        _pdfService;

    private readonly IConfiguration
        _configuration;

    public AppointmentShareController(
        IAppointmentShareService shareService,
        IAppointmentPdfService pdfService,
        IConfiguration configuration)
    {
        _shareService = shareService;
        _pdfService = pdfService;
        _configuration = configuration;
    }

    // CREER LE LIEN DE PARTAGE

    [Authorize]
    [HttpPost("create")]
    public IActionResult CreateShareLink(
        [FromBody] AppointmentShareInfo request)
    {
        if (string.IsNullOrWhiteSpace(
                request.AppointmentNo))
        {
            return BadRequest(new
            {
                message =
                    "Le numéro du rendez-vous est obligatoire."
            });
        }

        // Le lien est valide 30 jours.
        var lifetime =
            TimeSpan.FromDays(30);

        var token =
            _shareService.CreateToken(
                request,
                lifetime
            );

        var publicBaseUrl =
            _configuration["PublicBaseUrl"];

        if (string.IsNullOrWhiteSpace(
                publicBaseUrl))
        {
            return StatusCode(
                500,
                new
                {
                    message =
                        "PublicBaseUrl n'est pas configurée."
                }
            );
        }

        // Encode le token pour l'URL.
        var encodedToken =
            Uri.EscapeDataString(token);

        var shareUrl =
            $"{publicBaseUrl.TrimEnd('/')}" +
            $"/api/appointment-share/pdf" +
            $"?token={encodedToken}";

        return Ok(
            new AppointmentShareResponse
            {
                ShareUrl = shareUrl,

                ExpiresAt =
                    DateTime.UtcNow.Add(lifetime)
            }
        );
    }


  

    [AllowAnonymous]
    [HttpGet("pdf")]
    public IActionResult DownloadPdf(
        [FromQuery] string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return BadRequest(
                "Lien invalide."
            );
        }

        var appointment =
            _shareService.ReadToken(
                token
            );

        // Token invalide / modifié / expiré
        if (appointment == null)
        {
            return NotFound(
                "Ce lien est invalide ou a expiré."
            );
        }

        var pdfBytes =
            _pdfService.Generate(
                appointment
            );

        var safeAppointmentNo =
            MakeSafeFileName(
                appointment.AppointmentNo
            );

        var fileName =
            $"RDV_{safeAppointmentNo}.pdf";

        return File(
            pdfBytes,
            "application/pdf",
            fileName
        );
    }


    private static string MakeSafeFileName(
        string value)
    {
        foreach (
            var invalidCharacter
            in Path.GetInvalidFileNameChars())
        {
            value = value.Replace(
                invalidCharacter,
                '_'
            );
        }

        return value;
    }
}