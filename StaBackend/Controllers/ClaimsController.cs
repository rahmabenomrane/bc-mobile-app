
using Microsoft.AspNetCore.Mvc;
using StaBackend.Services;
using Microsoft.AspNetCore.Authorization;
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ClaimsController : ControllerBase
{
    private readonly IBcService _bc;
    private readonly ILogger<ClaimsController> _logger;

    public ClaimsController(IBcService bc, ILogger<ClaimsController> logger)
    {
        _bc = bc;
        _logger = logger;
    }

    // GET /api/claims/{claimNo}/messages
    [HttpGet("{claimNo}/messages")]
    public async Task<IActionResult> GetClaimMessages(string claimNo)
    {
        try
        {
            var messages = await _bc.GetClaimMessagesAsync(claimNo);

            return Ok(messages);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "[GET CLAIM MESSAGES] Erreur pour la réclamation {ClaimNo}",
                claimNo
            );

            return StatusCode(
                500,
                new { message = "Erreur lors de la récupération des échanges." }
            );
        }
    }


    // POST /api/claims/{claimNo}/messages
    [HttpPost("{claimNo}/messages")]
    public async Task<IActionResult> SendClaimMessage(
        string claimNo,
        [FromBody] ClaimMessageRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Message))
        {
            return BadRequest(
                new { message = "Le message est obligatoire." }
            );
        }

        try
        {
            var result = await _bc.CreateClaimMessageAsync(
                claimNo,
                CurrentCustomerNo,
                request.Message
            );

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "[SEND CLAIM MESSAGE] Erreur pour la réclamation {ClaimNo}",
                claimNo
            );

            return StatusCode(
                500,
                new { message = "Erreur lors de l'envoi du message." }
            );
        }
    }
    private string CurrentCustomerNo =>
        User.Claims.FirstOrDefault(c => c.Type == "CustomerNumber")?.Value ?? string.Empty;

    // // GET /api/claims
    [HttpGet]
    public async Task<IActionResult> GetClaims()
    {
        try
        {
            var claims = await _bc.GetClaimsAsync(CurrentCustomerNo);
            return Ok(claims);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[GET CLAIMS] Erreur pour {Customer}", CurrentCustomerNo);
            return StatusCode(500, new { message = "Erreur lors de la récupération." });
        }
    }

    // // POST /api/claims
    [HttpPost]
    public async Task<IActionResult> CreateClaim([FromBody] CreateClaimRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Description))
            return BadRequest(new { message = "La description est obligatoire." });

        if (request.Description.Length > 100)
            return BadRequest(new { message = "Description limitée à 100 caractères." });


        request.CustomerNo = CurrentCustomerNo;

        try
        {
            var result = await _bc.CreateClaimAsync(request);
            if (!result.Success)
                return BadRequest(new { message = result.Error });

            _logger.LogInformation(
                "[CREATE CLAIM] #{No} créée pour {Customer} | RDV: {Rdv}",
                result.ClaimNumber, result.CustomerNo, request.AppointmentRef);

            return CreatedAtAction(nameof(GetClaims), new { id = result.ClaimNumber }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[CREATE CLAIM] Erreur");
            return StatusCode(500, new { message = "Erreur lors de la création." });
        }
    }


    // PATCH /api/claims/{claimNumber}/status
    [HttpPatch("{claimNumber}/status")]
    public async Task<IActionResult> UpdateStatus(int claimNumber, [FromBody] UpdateClaimStatusRequest request)
    {
        try
        {
            await _bc.UpdateClaimStatusAsync(claimNumber, request.Status);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[UPDATE CLAIM] Erreur #{No}", claimNumber);
            return StatusCode(500, new { message = ex.Message });
        }
    }
}

public class UpdateClaimStatusRequest
{
    public int Status { get; set; }
}
public class ClaimMessageRequest
{
    public string Message { get; set; } = string.Empty;
}
