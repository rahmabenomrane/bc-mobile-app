namespace StaBackend.Models
{
    public sealed class AiDiagnosticResult
    {
        public bool ImageValide { get; set; }

        public bool VehiculeDetecte { get; set; }

        public string QualiteImage { get; set; } = string.Empty;

        public string ObservationVisible { get; set; } = string.Empty;

        public string? ServiceTypeDetecte { get; set; }

        public double Confiance { get; set; }

        public string Urgence { get; set; } = string.Empty;

        public string? ZoneConcernee { get; set; }

        public string Conseil { get; set; } = string.Empty;

        public bool DiagnosticCertain { get; set; }

        public bool BesoinInformationsSupplementaires { get; set; }

        public List<string> QuestionsSupplementaires { get; set; }
            = new List<string>();
        public string? ServiceCodeDetecte { get; set; }

        public string? ServiceLibelleDetecte { get; set; }

        public string? TypeServiceDetecte { get; set; }

        public bool CorrespondanceServiceTrouvee { get; set; }
        public List<BCAgencyService> AgencesRecommandees { get; set; }
            = new List<BCAgencyService>();
    }

    public sealed class DiagnosticRequest
    {
        public string? Description { get; set; }

        public IFormFile? Photo { get; set; }
    }
}