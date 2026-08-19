public enum ServiceType
{
    EntretienPeriodique = 0,
    DiagnosticElectronique = 1,
    Pneumatiques = 2,
    Climatisation = 4
}

public static class ServiceTypeMapper
{
    private static readonly Dictionary<string, ServiceType> Map = new()
    {
        { "Entretien périodique", ServiceType.EntretienPeriodique },
        { "Diagnostic électronique", ServiceType.DiagnosticElectronique },
        { "Pneumatiques", ServiceType.Pneumatiques },
        { "Climatisation", ServiceType.Climatisation }
    };

    public static ServiceType ToEnum(string label) => Map[label];
}