using Microsoft.AspNetCore.Mvc;
using StaBackend.Models;
using StaBackend.Services;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace StaBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IBcService _bcService;
        private readonly IConfiguration _configuration;

        public AuthController(IBcService bcService, IConfiguration configuration)
        {
            _bcService = bcService;
            _configuration = configuration;
        }

        // POST /api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                if (string.IsNullOrEmpty(request.Phone) ||
                    string.IsNullOrEmpty(request.Password))
                    return BadRequest(new { error = "Phone et password requis" });

                Console.WriteLine($"LOGIN ATTEMPT — Phone: {request.Phone}");

                var result = await _bcService.LoginAsync(request.Phone, request.Password);

                Console.WriteLine($"LOGIN RESULT — Success: {result.Success}, CustomerNumber: {result.CustomerNumber}, Error: {result.Error}");

                if (!result.Success)
                    return Unauthorized(new { error = result.Error });

                // ── Clé JWT null-safe ──────────────────────────────────────
                var jwtKey = _configuration["Jwt:Key"];
                Console.WriteLine($"JWT KEY présente : {!string.IsNullOrEmpty(jwtKey)}");

                if (string.IsNullOrEmpty(jwtKey))
                    return StatusCode(500, new { error = "Jwt:Key absent de appsettings.json" });

                var claims = new[]
                {
                    new Claim(ClaimTypes.Name,  request.Phone),
                    new Claim("CustomerNumber", result.CustomerNumber ?? string.Empty),
                };

                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
                var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                var token = new JwtSecurityToken(
                    issuer: "StaBackend",
                    audience: "StaMobile",
                    claims: claims,
                    expires: DateTime.UtcNow.AddDays(7),
                    signingCredentials: creds);

                var jwt = new JwtSecurityTokenHandler().WriteToken(token);
                Console.WriteLine($"TOKEN GÉNÉRÉ : {jwt}");

                return Ok(new
                {
                    success = true,
                    token = jwt,
                    customerNumber = result.CustomerNumber
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERREUR LOGIN : " + ex.ToString());
                return StatusCode(500, new
                {
                    error = ex.Message,
                    detail = ex.ToString()
                });
            }
        }

        // POST /api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                if (string.IsNullOrEmpty(request.Phone) ||
                    string.IsNullOrEmpty(request.Password))
                    return BadRequest(new { error = "Phone et password requis" });

                var result = await _bcService.RegisterAsync(request);

                if (!result.Success)
                    return BadRequest(new { error = result.Error });

                return StatusCode(201, result);
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERREUR REGISTER : " + ex.ToString());
                return StatusCode(500, new { error = ex.Message, detail = ex.ToString() });
            }
        }
        [HttpGet("customer/{customerNumber}")]
        public async Task<IActionResult> GetCustomer(string customerNumber)
        {
            var email = await _bcService.GetCustomerEmailAsync(customerNumber);
            return Ok(new { email });
        }

        // POST /api/auth/logout
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            var token = Request.Headers["x-session-token"].ToString();

            if (string.IsNullOrEmpty(token))
                return BadRequest(new { error = "Token requis" });

            await _bcService.LogoutAsync(token);
            return Ok(new { success = true, message = "Déconnecté" });
        }
    }
}