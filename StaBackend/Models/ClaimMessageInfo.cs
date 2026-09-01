public class ClaimMessageInfo
{
    public int EntryNo { get; set; }

    public string ClaimNo { get; set; } = string.Empty;

    public string Message { get; set; } = string.Empty;

    public string SenderType { get; set; } = string.Empty;

    public string SenderName { get; set; } = string.Empty;

    public DateTime? MessageDateTime { get; set; }
}