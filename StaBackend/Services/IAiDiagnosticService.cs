using StaBackend.Models;

namespace StaBackend.Services;

public interface IAiDiagnosticService
{
    Task<AiDiagnosticResult> AnalyzeAsync(
        byte[] imageBytes,
        string mimeType,
        string? userDescription,
        IReadOnlyCollection<BCServiceModel> availableServices,
        CancellationToken cancellationToken = default
    );
}