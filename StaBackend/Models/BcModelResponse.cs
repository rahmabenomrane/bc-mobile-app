using System.Text.Json.Serialization;

public class BcModelResponse
{
    [JsonPropertyName("value")]
    public List<BcModel> Value { get; set; }
}

public class BcModel
{
    [JsonPropertyName("code")]
    public string Code { get; set; }

    [JsonPropertyName("makeCode")]
    public string MakeCode { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; }
}