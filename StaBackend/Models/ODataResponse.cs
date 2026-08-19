namespace StaBackend.Models;

public class ODataResponse<T>
{
    public List<T> value { get; set; } = new();
}