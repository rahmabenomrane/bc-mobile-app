using System.Text.Json.Serialization;

public class BcMakeResponse
{
    [JsonPropertyName("value")]
    public List<BcMake> Value { get; set; }
}

public class BcMake
{
    [JsonPropertyName("code")]
    public string Code { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; }
}