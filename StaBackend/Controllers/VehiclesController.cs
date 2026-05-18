using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;
using Microsoft.AspNetCore.Authorization;


namespace StaBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VehiclesController : ControllerBase
    {
        private readonly IBcService _bcService;
        private readonly ILogger<VehiclesController> _logger;

        public VehiclesController(
            IBcService bcService,
            ILogger<VehiclesController> logger)
        {
            _bcService = bcService;
            _logger = logger;
        }


        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetUserVehicles()
        {
            Console.WriteLine("GET VEHICLES APPELÉ");
            Console.WriteLine("AUTH HEADER:");
            Console.WriteLine(Request.Headers["Authorization"]);

            try
            {
                var customerNum =
                    User.FindFirst("CustomerNumber")?.Value;

                Console.WriteLine($"CustomerNum = {customerNum}");

                if (string.IsNullOrWhiteSpace(customerNum))
                {
                    Console.WriteLine("CustomerNumber NULL");

                    return Unauthorized(new
                    {
                        success = false,
                        message = "CustomerNumber manquant"
                    });
                }

                var vehicles = await _bcService
                    .GetCustomerVehiclesAsync(customerNum);

                return Ok(new
                {
                    success = true,
                    data = vehicles
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());

                return StatusCode(500);
            }
        }
    }
}