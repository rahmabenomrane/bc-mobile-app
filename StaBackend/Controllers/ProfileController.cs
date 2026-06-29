using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StaBackend.Models;
using StaBackend.Services;
using System.Security.Claims;

namespace StaBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]  // 🔒 Toutes les actions nécessitent authentification
    public class ProfileController : ControllerBase
    {
        private readonly IBcService _bcService;
        private readonly ILogger<ProfileController> _logger;

        public ProfileController(IBcService bcService, ILogger<ProfileController> logger)
        {
            _bcService = bcService;
            _logger = logger;
        }

        // GET /api/profile
        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                // Récupérer le CustomerNumber depuis le JWT
                var customerNumber = User.FindFirst("CustomerNumber")?.Value;

                if (string.IsNullOrEmpty(customerNumber))
                    return Unauthorized(new { error = "Customer number not found in token" });

                Console.WriteLine($"GET PROFILE — CustomerNumber: {customerNumber}");

                // Récupérer les infos du client depuis BC
                // Note: Vous devez ajouter cette méthode dans IBcService
                var customer = await _bcService.GetCustomerByNumberAsync(customerNumber);

                if (customer == null)
                    return NotFound(new { error = "Customer not found" });

                return Ok(new
                {
                    success = true,
                    customer = new
                    {
                        customerNumber = customer.NumCustomer,
                        lastName = customer.Name,
                        firstName = customer.FirstName,
                        address = customer.Address,
                        phone = customer.Phone,
                        email = customer.Email,
                        civility = customer.Civility
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR GET PROFILE: {ex.Message}");
                return StatusCode(500, new { error = "Internal server error", detail = ex.Message });
            }
        }
        // PATCH /api/profile/password
        [HttpPatch("password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                var customerNumber = User.FindFirst("CustomerNumber")?.Value;
                if (string.IsNullOrEmpty(customerNumber))
                    return Unauthorized(new { error = "Customer number not found in token" });

                // 1. Validation basique
                if (string.IsNullOrEmpty(request.CurrentPassword) ||
                    string.IsNullOrEmpty(request.NewPassword) ||
                    string.IsNullOrEmpty(request.ConfirmPassword))
                    return BadRequest(new { error = "All fields are required" });

                if (request.NewPassword != request.ConfirmPassword)
                    return BadRequest(new { error = "Passwords do not match" });

                if (request.NewPassword.Length < 6)
                    return BadRequest(new { error = "New password must be at least 6 characters" });

                if (request.CurrentPassword == request.NewPassword)
                    return BadRequest(new { error = "New password must be different from current password" });

                // 2. Vérifier l'ancien mot de passe et mettre à jour
                var result = await _bcService.ChangePasswordAsync(
    customerNumber,
    request.CurrentPassword,
    request.NewPassword
);

                if (!result.Success)
                {
                    var errorMsg = string.IsNullOrEmpty(result.Error)
                        ? "BC returned an error with no details"
                        : result.Error;

                    _logger.LogWarning($"BC password change failed for {customerNumber}: {errorMsg}");
                    return BadRequest(new { error = errorMsg });
                }
                _logger.LogInformation($"Password changed for customer {customerNumber}");
                return Ok(new { success = true, message = "Password changed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password");
                return StatusCode(500, new { error = "Internal server error", detail = ex.Message });
            }
        }
        // PATCH /api/profile
        [HttpPatch]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            try
            {
                // 1. Vérifier l'authentification
                var customerNumber = User.FindFirst("CustomerNumber")?.Value;

                if (string.IsNullOrEmpty(customerNumber))
                    return Unauthorized(new { error = "Customer number not found in token" });

                Console.WriteLine($"UPDATE PROFILE — CustomerNumber: {customerNumber}");
                Console.WriteLine($"UPDATE DATA — LastName: {request.LastName}, Phone: {request.Phone}, Email: {request.Email}");

                // 2. Vérifier qu'au moins un champ est à modifier
                if (IsEmptyRequest(request))
                    return BadRequest(new { error = "At least one field is required for update" });

                // 3. Validation des données
                var validationError = ValidateUpdateRequest(request);
                if (validationError != null)
                    return BadRequest(new { error = validationError });

                // 4. Vérifier unicité du phone (si changé)
                if (!string.IsNullOrEmpty(request.Phone))
                {
                    var isPhoneUnique = await _bcService.IsPhoneUniqueAsync(request.Phone, customerNumber);
                    if (!isPhoneUnique)
                        return BadRequest(new { error = "Phone number already used by another account" });
                }

                // 5. Vérifier unicité de l'email (si changé)
                if (!string.IsNullOrEmpty(request.Email))
                {
                    var isEmailUnique = await _bcService.IsEmailUniqueAsync(request.Email, customerNumber);
                    if (!isEmailUnique)
                        return BadRequest(new { error = "Email already used by another account" });
                }

                // 6. Appeler BC pour mettre à jour
                var result = await _bcService.UpdateCustomerProfileAsync(customerNumber, request);

                if (!result.Success)
                    return BadRequest(new { error = result.Error });

                // 7. Log l'action
                _logger.LogInformation($"Profile updated for customer {customerNumber}");
                Console.WriteLine($"PROFILE UPDATED SUCCESSFULLY — Customer: {customerNumber}");

                return Ok(new
                {
                    success = true,
                    message = "Profile updated successfully",
                    updatedFields = GetUpdatedFieldsList(request)
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR UPDATE PROFILE: {ex.Message}");
                _logger.LogError(ex, "Error updating profile");
                return StatusCode(500, new { error = "Internal server error", detail = ex.Message });
            }
        }

        // Helper methods
        private bool IsEmptyRequest(UpdateProfileRequest request)
        {
            return string.IsNullOrEmpty(request.LastName) &&
                   string.IsNullOrEmpty(request.FirstName) &&
                   string.IsNullOrEmpty(request.Address) &&
                   string.IsNullOrEmpty(request.Phone) &&
                   string.IsNullOrEmpty(request.Email) &&
                   string.IsNullOrEmpty(request.Civility);
        }

        private string? ValidateUpdateRequest(UpdateProfileRequest request)
        {
            if (!string.IsNullOrEmpty(request.Phone) && request.Phone.Length < 8)
                return "Phone number must be at least 8 characters";

            if (!string.IsNullOrEmpty(request.Email) && !request.Email.Contains("@"))
                return "Invalid email format";

            if (!string.IsNullOrEmpty(request.Civility) &&
                request.Civility != "Mr" &&
                request.Civility != "Mme" &&
                request.Civility != "Mlle")
                return "Civility must be Mr, Mme, or Mlle";

            return null;
        }

        private List<string> GetUpdatedFieldsList(UpdateProfileRequest request)
        {
            var fields = new List<string>();
            if (request.LastName != null) fields.Add("lastName");
            if (request.FirstName != null) fields.Add("firstName");
            if (request.Address != null) fields.Add("address");
            if (request.Phone != null) fields.Add("phone");
            if (request.Email != null) fields.Add("email");
            if (request.Civility != null) fields.Add("civility");
            return fields;
        }
    }

}