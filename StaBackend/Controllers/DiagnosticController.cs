using Microsoft.AspNetCore.Mvc;
using StaBackend.Models;
using StaBackend.Services;

namespace StaBackend.Controllers
{
    [ApiController]
    [Route("api/diagnostic")]
    public sealed class DiagnosticController : ControllerBase
    {
        private readonly IAiDiagnosticService _aiDiagnosticService;
        private readonly IBcService _bcService;

        public DiagnosticController(
            IAiDiagnosticService aiDiagnosticService,
            IBcService bcService)
        {
            _aiDiagnosticService = aiDiagnosticService;
            _bcService = bcService;
        }

        [HttpPost("analyze")]
        public async Task<IActionResult> Analyze(
            [FromForm] DiagnosticRequest request,
            CancellationToken cancellationToken)
        {

            try
            {
                if (request.Photo is null ||
                    request.Photo.Length == 0)
                {
                    return BadRequest(new
                    {
                        message = "Veuillez sélectionner une photo."
                    });
                }

                byte[] imageBytes;

                await using (
                    var memoryStream = new MemoryStream())
                {
                    await request.Photo.CopyToAsync(
                        memoryStream,
                        cancellationToken
                    );

                    imageBytes = memoryStream.ToArray();
                }
                var servicesDisponibles = await _bcService.GetAllServicesAsync();

                Console.WriteLine(
                    $"[BC] Nombre de services envoyés à Ollama : " +
                    $"{servicesDisponibles.Count}"
                );

                foreach (var service in servicesDisponibles)
                {
                    Console.WriteLine(
                        $"[BC] {service.serviceCode} | " +
                        $"{service.libelle} | " +
                        $"{service.description} | " +
                        $"{service.typeService}"
                    );
                }

                // 1. Analyse de l'image avec Ollama
                var diagnostic =
      await _aiDiagnosticService.AnalyzeAsync(
          imageBytes,
          request.Photo.ContentType,
          request.Description,
          servicesDisponibles,
          cancellationToken
      );

                // 2. Initialiser la liste
                diagnostic.AgencesRecommandees =
                    new List<BCAgencyService>();


                // 3. Chercher les agences qui proposent
                // exactement le service détecté
                if (diagnostic.ImageValide &&
                    diagnostic.VehiculeDetecte &&
                    diagnostic.CorrespondanceServiceTrouvee &&
                    !string.IsNullOrWhiteSpace(
                        diagnostic.ServiceCodeDetecte))
                {
                    diagnostic.AgencesRecommandees =
                        await _bcService
                            .GetAgenciesByServiceCodeAsync(
                                diagnostic.ServiceCodeDetecte
                            );
                }

                // 4. La liste des agences sera incluse
                // automatiquement dans la réponse JSON
                return Ok(diagnostic);
            }
            catch (TaskCanceledException)
            {
                return StatusCode(504, new
                {
                    message =
                        "L’analyse locale a dépassé le délai autorisé."
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);

                return StatusCode(500, new
                {
                    message =
                        "Une erreur est survenue pendant le diagnostic.",
                    detail = ex.Message
                });
            }
        }
    }
}