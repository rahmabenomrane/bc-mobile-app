using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Options;

public class EmailService
{
  private readonly EmailSettings _settings;

  public EmailService(IOptions<EmailSettings> settings)
  {
    _settings = settings.Value;
  }

  public async Task SendReminderEmailAsync(
  string toEmail,
  string customerName,
  string appointmentNo,
  string agencyName,
  string serviceName,
  string date,
  string time)
  {
    var subject = "Rappel de votre rendez-vous demain — STA Garage";

    var body = $@"
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <style>
    body {{ font-family: 'Segoe UI', sans-serif; background: #f4f6fb; margin: 0; padding: 0; }}
    .container {{ max-width: 600px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }}
    .header {{ background: linear-gradient(135deg, #f97316, #ea580c); padding: 32px; text-align: center; }}
    .header h1 {{ color: white; margin: 0; font-size: 24px; }}
    .header p {{ color: rgba(255,255,255,0.85); margin: 8px 0 0; }}
    .body {{ padding: 32px; }}
    .info-card {{ background: #f4f6fb; border-radius: 12px; padding: 20px; margin: 20px 0; }}
    .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eeeef5; }}
    .info-row:last-child {{ border-bottom: none; }}
    .info-label {{ color: #9e9ebf; font-size: 13px; }}
    .info-value {{ color: #2d2d4e; font-size: 13px; font-weight: 600; }}
    .footer {{ text-align: center; padding: 20px; color: #9e9ebf; font-size: 12px; border-top: 1px solid #eeeef5; }}
  </style>
</head>
<body>
  <div class='container'>
    <div class='header'>
      <h1>🔧 STA Garage</h1>
      <p>Rappel — Vous avez un rendez-vous demain</p>
    </div>
    <div class='body'>
      <p style='color:#2d2d4e;'>Bonjour <strong>{customerName}</strong>,</p>
      <p style='color:#6b6b8e;'>Ceci est un rappel automatique. Vous avez un rendez-vous prévu <strong>demain</strong>.</p>

      <div class='info-card'>
        <div class='info-row'>
          <span class='info-label'>N° RDV</span>
          <span class='info-value'>{appointmentNo}</span>
        </div>
        <div class='info-row'>
          <span class='info-label'>Agence</span>
          <span class='info-value'>{agencyName}</span>
        </div>
        <div class='info-row'>
          <span class='info-label'>Service</span>
          <span class='info-value'>{serviceName}</span>
        </div>
        <div class='info-row'>
          <span class='info-label'>Date</span>
          <span class='info-value'>{date}</span>
        </div>
        <div class='info-row'>
          <span class='info-label'>Heure</span>
          <span class='info-value'>{time}</span>
        </div>
      </div>

      <p style='color:#9e9ebf; font-size:12px; text-align:center;'>
        Si vous souhaitez annuler ou modifier votre rendez-vous, contactez-nous dès que possible.
      </p>
    </div>
    <div class='footer'>
      © 2026 STA Garage — Tous droits réservés
    </div>
  </div>
</body>
</html>";

    using var smtp = new SmtpClient(_settings.SmtpHost, _settings.SmtpPort)
    {
      Credentials = new NetworkCredential(_settings.SenderEmail, _settings.AppPassword),
      EnableSsl = true,
    };

    var mail = new MailMessage
    {
      From = new MailAddress(_settings.SenderEmail, _settings.SenderName),
      Subject = subject,
      Body = body,
      IsBodyHtml = true,
    };
    mail.To.Add(toEmail);

    await smtp.SendMailAsync(mail);
    Console.WriteLine($"✅ Email rappel envoyé à {toEmail}");
  }
}