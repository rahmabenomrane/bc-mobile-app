using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;
[ApiController]
[Route("api/[controller]")]
public class AppointmentController : ControllerBase
{
    private readonly IBcService _bcService;

    public AppointmentController(IBcService bcService)
    {
        _bcService = bcService;
    }

    [HttpGet("slots")]
    public async Task<IActionResult> GetSlots(
        [FromQuery] string agencyCode,
        [FromQuery] string serviceCode)
    {
        var slots = await _bcService.GetAppointmentsAsync(
            agencyCode,
            serviceCode);

        return Ok(slots);
    }
    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateAppointmentDto dto)
    {
        var result = await _bcService.CreateAppointmentAsync(dto);
        return Ok(result);
    }
    [HttpGet("customer/{customerNumber}")]
    public async Task<IActionResult> GetCustomerAppointments(
        string customerNumber)
    {
        var rdvs =
            await _bcService.GetCustomerAppointmentsAsync(customerNumber);

        return Ok(rdvs);
    }

}