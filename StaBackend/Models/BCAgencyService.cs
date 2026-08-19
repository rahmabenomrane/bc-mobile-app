using System.Text.Json.Serialization;

public class BCAgencyService
{
    [JsonPropertyName("agencyCode")]
    public string AgencyCode { get; set; } = "";

    [JsonPropertyName("serviceCode")]
    public string ServiceCode { get; set; } = "";

    [JsonPropertyName("disponible")]
    public bool Disponible { get; set; }

    [JsonPropertyName("agencyName")]
    public string AgencyName { get; set; } = "";
    [JsonPropertyName("address")]
    public string Address { get; set; } = "";
}