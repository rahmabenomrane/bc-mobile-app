using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;



[ApiController]
[Route("api/services")]
public class ServicesController : ControllerBase
{
    [HttpGet("test")]
    public IActionResult Test()
    {
        return Ok("Services controller OK");
    }
    private readonly IBcService _bcService;

    public ServicesController(IBcService bcService)
    {
        _bcService = bcService;
    }

    [HttpGet("agency/{agencyCode}")]
    public async Task<IActionResult> GetServicesByAgency(string agencyCode)
    {
        var services =
            await _bcService.GetServicesByAgencyAsync(agencyCode);

        return Ok(services);
    }
}