public class ConfirmationTokenStore
{
    private readonly Dictionary<string, TokenEntry> _tokens = new();

    public string GenerateToken(string appointmentNo)
    {
        var token = Guid.NewGuid().ToString("N");
        _tokens[token] = new TokenEntry
        {
            AppointmentNo = appointmentNo,
            ExpiresAt = DateTime.UtcNow.AddHours(24),
        };
        return token;
    }

    public string? GetAppointmentNo(string token)
    {
        if (!_tokens.TryGetValue(token, out var entry)) return null;
        if (entry.ExpiresAt < DateTime.UtcNow)
        {
            _tokens.Remove(token);
            return null;
        }
        return entry.AppointmentNo;
    }

    public void RemoveToken(string token) => _tokens.Remove(token);
}

public class TokenEntry
{
    public string AppointmentNo { get; set; }
    public DateTime ExpiresAt { get; set; }
}