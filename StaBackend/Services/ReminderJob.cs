
public class ReminderJob : BackgroundService
{
    private readonly IServiceProvider _services;

    public ReminderJob(IServiceProvider services)
    {
        _services = services;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var now = DateTime.Now;
            // Prochaine exécution à 10h00
            var next = DateTime.Today.AddHours(10);
            if (now > next) next = next.AddDays(1);

            var delay = next - now;
            await Task.Delay(delay, stoppingToken);

            // Appeler l'endpoint de rappel
            using var scope = _services.CreateScope();
            var http = scope.ServiceProvider.GetRequiredService<IHttpClientFactory>().CreateClient();
            await http.PostAsync("http://localhost:5032/api/Appointment/send-reminders", null, stoppingToken);

            Console.WriteLine($"✅ Job rappel exécuté à {DateTime.Now}");
        }
    }
}