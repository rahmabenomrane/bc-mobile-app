using System.Text.Json.Serialization;
using VehicleDto = StaBackend.Models.VehicleDto;
public class BcVehicleResponse
{
    [JsonPropertyName("@odata.context")]
    public string? OdataContext { get; set; }

    public List<VehicleDto>? value { get; set; }
}
