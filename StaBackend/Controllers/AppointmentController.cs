using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;
using Microsoft.AspNetCore.Authorization;
[ApiController]
[Route("api/[controller]")]
public class AppointmentController : ControllerBase
{
    private readonly IBcService _bcService;

    private readonly EmailService _emailService;
    private readonly ConfirmationTokenStore _tokenStore;
    public AppointmentController(
    IBcService bcService,
    EmailService emailService,
    ConfirmationTokenStore tokenStore)
    {
        _bcService = bcService;
        _emailService = emailService;
        _tokenStore = tokenStore;
    }


    [HttpGet("slots")]
    public async Task<IActionResult> GetSlots(
        [FromQuery] string agencyCode,
        [FromQuery] string serviceCode)
    {
        var slots = await _bcService.GetAppointmentsAsync(
            agencyCode,
            serviceCode);

        return Ok(slots);
    }
    // [HttpPost("create")]
    // public async Task<IActionResult> Create([FromBody] CreateAppointmentDto dto)
    // {
    //     var result = await _bcService.CreateAppointmentAsync(dto);
    //     return Ok(result);
    // }


    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateAppointmentDto dto)
    {
        var result = await _bcService.CreateAppointmentAsync(dto);
        return Ok(result);
    }


    [HttpPost("send-reminders")]
    public async Task<IActionResult> SendReminders()
    {
        var tomorrow = DateTime.Now.AddDays(1).Date;
        var allRdvs = await _bcService.GetAppointmentsByDateAsync(tomorrow);

        int sent = 0;
        foreach (var rdv in allRdvs)
        {
            var vehicles = await _bcService.GetCustomerVehiclesAsync(rdv.NumVehicle);
            var vehicle = vehicles.FirstOrDefault();
            if (vehicle == null) continue;

            var email = await _bcService.GetCustomerEmailAsync(vehicle.NumCustomer);
            if (string.IsNullOrEmpty(email)) continue;

            var agencies = await _bcService.GetAgenciesAsync();
            var agency = agencies.FirstOrDefault(a => a.Code == rdv.AgencyCode);

            await _emailService.SendReminderEmailAsync(
                toEmail: email,
                customerName: vehicle.NumCustomer,
                appointmentNo: rdv.AppointmentNo,
                agencyName: agency?.Name ?? rdv.AgencyCode,
                serviceName: rdv.ServiceCode,
                date: rdv.StartTime.ToString("dd/MM/yyyy"),
                time: rdv.StartTime.ToString("HH:mm")
            );
            sent++;
        }

        return Ok(new { sent, message = $"{sent} rappels envoyés" });
    }

    [HttpGet("customer/{customerNumber}")]
    public async Task<IActionResult> GetCustomerAppointments(
        string customerNumber)
    {
        var rdvs =
            await _bcService.GetCustomerAppointmentsAsync(customerNumber);

        return Ok(rdvs);
    }
    [HttpPost("reschedule")]
    public async Task<IActionResult> Reschedule([FromBody] RescheduleAppointmentDto dto)
    {
        var result = await _bcService.RescheduleAppointmentAsync(dto);
        return Ok(result);
    }
    [HttpGet("confirm")]
    [AllowAnonymous]
    public async Task<IActionResult> ConfirmAppointment([FromQuery] string token)
    {
        var appointmentNo = _tokenStore.GetAppointmentNo(token);

        if (appointmentNo == null)
            return Content("<h2> Lien invalide ou expiré.</h2>", "text/html");

        await _bcService.ConfirmAppointmentAsync(appointmentNo);
        _tokenStore.RemoveToken(token);

        return Content(@"
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Confirmation</title>
        <style>
            body {
                margin: 0;
                padding: 0;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                background: linear-gradient(120deg, #84fab0 0%, #8fd3f4 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            
            .card {
                background: white;
                border-radius: 32px;
                padding: 48px 32px;
                max-width: 450px;
                margin: 20px;
                text-align: center;
                box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
                animation: slideUp 0.5s ease;
            }
            
            .checkmark {
                width: 80px;
                height: 80px;
                background:rgb(74, 200, 222);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 24px;
                animation: bounce 0.5s ease;
            }
            
            .checkmark:after {
                content: '✓';
                color: white;
                font-size: 48px;
                font-weight: bold;
            }
            
            h1 {
                color: #1e293b;
                font-size: 28px;
                margin: 0 0 12px;
            }
            
            p {
                color: #64748b;
                font-size: 16px;
                line-height: 1.5;
                margin: 0 0 8px;
            }
            
            .highlight {
                background: #f1f5f9;
                border-radius: 16px;
                padding: 16px;
                margin: 24px 0;
                font-size: 14px;
                color: #475569;
            }
            
            .emoji {
                font-size: 32px;
                margin: 16px 0 8px;
            }
            
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(40px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            @keyframes bounce {
                0%, 100% { transform: scale(1); }
                50% { transform: scale(1.1); }
            }
            
            button {
                background: #3b82f6;
                color: white;
                border: none;
                padding: 10px 24px;
                border-radius: 40px;
                font-size: 14px;
                margin-top: 16px;
                cursor: pointer;
                transition: background 0.2s;
            }
            
            button:hover {
                background: #2563eb;
            }
        </style>
    </head>
    <body>
        <div class='card'>
            <div class='checkmark'></div>
            <h1>✓ Rendez-vous confirmé</h1>
            <p>Votre rendez-vous a été enregistré avec succès.</p>
            <div class='highlight'>
                📅 Un récapitulatif vous a été envoyé par email
            </div>
            <p style='font-size: 13px; color: #94a3b8;'>Cette page se fermera automatiquement</p>
        </div>
        <script>setTimeout(() => window.close(), 4000);</script>
    </body>
    </html>
", "text/html");
    }

    [HttpPost("cancel/{appointmentNo}")]
    public async Task<IActionResult> Cancel(string appointmentNo)
    {
        await _bcService.CancelAppointmentAsync(appointmentNo);
        return Ok();
    }

}