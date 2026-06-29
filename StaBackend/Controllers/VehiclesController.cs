using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;
using Microsoft.AspNetCore.Authorization;
using StaBackend.Models;

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
        [AllowAnonymous]
        [HttpGet("test")]
        public IActionResult Test()
        {
            return Ok(new { message = "API fonctionne", status = "OK" });
        }
        [AllowAnonymous]
        [HttpGet("makes")]
        public async Task<IActionResult> GetMakes()
        {
            try
            {
                var makes = await _bcService.GetMakesAsync();

                return Ok(new
                {
                    success = true,
                    data = makes
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting makes");
                return StatusCode(500);
            }
        }
        [AllowAnonymous]
        [HttpGet("models/{makeCode}")]
        public async Task<IActionResult> GetModels(string makeCode)
        {
            try
            {
                var models = await _bcService.GetModelsByMakeAsync(makeCode);

                return Ok(new
                {
                    success = true,
                    data = models
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting models");
                return StatusCode(500);
            }
        }
        [Authorize]
        [HttpPost]
        public async Task<IActionResult> CreateVehicle([FromBody] CreateVehicleDto dto)
        {
            try
            {
                var customerNum = User.FindFirst("CustomerNumber")?.Value;

                if (string.IsNullOrWhiteSpace(customerNum))
                    return Unauthorized(new { success = false, message = "CustomerNumber manquant" });

       
                dto.NumCustomer = customerNum;

                var success = await _bcService.CreateVehicleAsync(dto);

                if (!success)
                    return BadRequest(new { success = false, message = "Erreur lors de la création" });

                return Ok(new { success = true, message = "Véhicule créé avec succès" });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return StatusCode(500);
            }
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

                Console.WriteLine("=================================");
                Console.WriteLine($"Customer JWT = {customerNum}");
                Console.WriteLine("=================================");
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