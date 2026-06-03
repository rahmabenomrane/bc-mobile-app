
using Microsoft.AspNetCore.Mvc;
using StaBackend.Models;
using StaBackend.Services;

namespace StaBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AgencyController : ControllerBase
    {
        private readonly IBcService _bcService;

        public AgencyController(IBcService bcService)
        {
            _bcService = bcService;
        }

        // GET /api/agency
        // [HttpGet]
        // public async Task<IActionResult> GetAgencies()
        // {
        //     var agencies = await _bcService.GetAgenciesAsync();
        //     return Ok(agencies);
        // }

        [HttpGet]
        public async Task<IActionResult> GetAgencies()
        {
            Console.WriteLine("=== GET AGENCIES APPELÉ ===");
            Console.WriteLine($"AUTH HEADER: {Request.Headers["Authorization"]}");

            try
            {
                var agencies = await _bcService.GetAgenciesAsync();
                Console.WriteLine($"=== {agencies.Count} agences trouvées ===");
                return Ok(new { success = true, data = agencies });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== ERREUR : {ex.Message} ===");
                return StatusCode(500, new { success = false, error = ex.Message });
            }
        }
    }
}