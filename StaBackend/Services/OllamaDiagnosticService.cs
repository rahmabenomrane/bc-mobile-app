using System.Text;
using System.Text.Json;
using StaBackend.Models;

namespace StaBackend.Services;

public sealed class OllamaDiagnosticService : IAiDiagnosticService
{
    private static readonly string[] AllowedServices =
    {
        "Entretien périodique",
        "Diagnostic électronique",
        "Pneumatiques",
        "Climatisation"
    };

    private readonly HttpClient _httpClient;

    public OllamaDiagnosticService(HttpClient httpClient)
    {
        _httpClient = httpClient;
        _httpClient.BaseAddress = new Uri("http://localhost:11434");
    }
    private static string BuildServicesCatalog(
        IReadOnlyCollection<BCServiceModel> services)
    {
        if (services.Count == 0)
        {
            return "Aucun service disponible.";
        }

        return string.Join(
            "\n",
            services.Select(service =>
                $"- Code : {service.serviceCode}\n" +
                $"  Libellé : {service.libelle}\n" +
                $"  Description : {service.description}\n" +
                $"  Type : {service.typeService}"
            )
        );
    }
    public async Task<AiDiagnosticResult> AnalyzeAsync(
     byte[] imageBytes,
     string mimeType,
     string? userDescription,
     IReadOnlyCollection<BCServiceModel> availableServices,
     CancellationToken cancellationToken = default)
    {
        if (imageBytes is null || imageBytes.Length == 0)
        {
            throw new ArgumentException("L’image envoyée est vide.");
        }

        string imageBase64 = Convert.ToBase64String(imageBytes);
        string servicesCatalog =
    BuildServicesCatalog(availableServices);

        Console.WriteLine(
            "[OLLAMA] Catalogue envoyé :\n" +
            servicesCatalog
        );

        string prompt =
            BuildPrompt(
                userDescription,
                servicesCatalog
            );

        var requestBody = new
        {
            model = "gemma3:12b",
            messages = new object[]
            {
                new
                {
                    role = "user",
                    content = prompt,
                    images = new[] { imageBase64 }
                }
            },
            stream = false,
            format = CreateDiagnosticSchema(),
            options = new
            {
                // Valeur basse pour limiter les réponses inventées.
                temperature = 0.0,
                top_p = 0.2
            }
        };

        string requestJson = JsonSerializer.Serialize(requestBody);

        using var requestContent = new StringContent(
            requestJson,
            Encoding.UTF8,
            "application/json"
        );

        Console.WriteLine("[OLLAMA] Envoi de l’image au modèle local...");

        using HttpResponseMessage response = await _httpClient.PostAsync(
            "/api/chat",
            requestContent,
            cancellationToken
        );

        string responseJson = await response.Content.ReadAsStringAsync(
            cancellationToken
        );

        Console.WriteLine(
            $"[OLLAMA] Statut : {(int)response.StatusCode}"
        );

        if (!response.IsSuccessStatusCode)
        {
            Console.WriteLine($"[OLLAMA] Erreur : {responseJson}");

            throw new InvalidOperationException(
                $"Ollama a retourné le statut {(int)response.StatusCode}. " +
                $"Réponse : {responseJson}"
            );
        }

        using JsonDocument document = JsonDocument.Parse(responseJson);

        if (!document.RootElement.TryGetProperty(
                "message",
                out JsonElement messageElement))
        {
            throw new InvalidOperationException(
                "La réponse Ollama ne contient pas 'message'."
            );
        }

        if (!messageElement.TryGetProperty(
                "content",
                out JsonElement contentElement))
        {
            throw new InvalidOperationException(
                "La réponse Ollama ne contient pas 'content'."
            );
        }

        string? diagnosticJson = contentElement.GetString();

        if (string.IsNullOrWhiteSpace(diagnosticJson))
        {
            throw new InvalidOperationException(
                "Ollama a retourné une réponse vide."
            );
        }

        Console.WriteLine($"[OLLAMA] Diagnostic brut : {diagnosticJson}");

        AiDiagnosticResult? result;

        try
        {
            result = JsonSerializer.Deserialize<AiDiagnosticResult>(
                diagnosticJson,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                }
            );
        }
        catch (JsonException ex)
        {
            throw new InvalidOperationException(
                "Le modèle local a retourné un JSON invalide.",
                ex
            );
        }

        if (result is null)
        {
            throw new InvalidOperationException(
                "Impossible de convertir la réponse Ollama."
            );
        }

        result = ValidateResult(result, userDescription);

        Console.WriteLine(
            $"[OLLAMA] Diagnostic validé : " +
            $"{JsonSerializer.Serialize(result)}"
        );

        return result;
    }

    private static string BuildPrompt(
     string? description,
     string servicesCatalog)
    {
        string userDescription =
            string.IsNullOrWhiteSpace(description)
                ? "Aucune description fournie."
                : description.Trim();

        return $$"""
Tu es un assistant de pré-diagnostic automobile.

DESCRIPTION DU CLIENT :
{{userDescription}}

SERVICES DISPONIBLES DANS BUSINESS CENTRAL :
{{servicesCatalog}}

Analyse l'image et la description.

Choisis au maximum un seul service dans le catalogue.

Règles :

- Retourne uniquement un code réellement présent dans le catalogue.
- Ne crée jamais un code.
- Il n'est pas nécessaire de connaître la cause exacte pour orienter
  le client vers un service adapté.
- Un voyant de pression d'huile peut être orienté vers le service
  du catalogue dont le libellé ou la description correspond au contrôle,
  au diagnostic ou à l'entretien du moteur.
- Si aucun service ne correspond, retourne null.
- Ne choisis pas un service sans rapport uniquement pour remplir la réponse.

Réponds uniquement avec ce JSON :

{
  "imageValide": true,
  "vehiculeDetecte": true,
  "observationVisible": "",
  "serviceCodeDetecte": null,
  "serviceLibelleDetecte": null,
  "typeServiceDetecte": null,
  "correspondanceServiceTrouvee": false,
  "urgence": "Non déterminée",
  "zoneConcernee": "",
  "conseil": "",
  "besoinInformationsSupplementaires": false,
  "questionsSupplementaires": []
}
""";
    }
    private static object CreateDiagnosticSchema()
    {
        return new
        {
            type = "object",

            properties = new
            {
                imageValide = new
                {
                    type = "boolean"
                },

                vehiculeDetecte = new
                {
                    type = "boolean"
                },

                observationVisible = new
                {
                    type = "string"
                },

                serviceCodeDetecte = new
                {
                    type = new[] { "string", "null" }
                },

                serviceLibelleDetecte = new
                {
                    type = new[] { "string", "null" }
                },

                typeServiceDetecte = new
                {
                    type = new[] { "string", "null" }
                },

                correspondanceServiceTrouvee = new
                {
                    type = "boolean"
                },

                urgence = new
                {
                    type = "string"
                },

                zoneConcernee = new
                {
                    type = "string"
                },

                conseil = new
                {
                    type = "string"
                },

                besoinInformationsSupplementaires = new
                {
                    type = "boolean"
                },

                questionsSupplementaires = new
                {
                    type = "array",
                    items = new
                    {
                        type = "string"
                    }
                }
            },

            required = new[]
            {
            "imageValide",
            "vehiculeDetecte",
            "observationVisible",
            "serviceCodeDetecte",
            "serviceLibelleDetecte",
            "typeServiceDetecte",
            "correspondanceServiceTrouvee",
            "urgence",
            "zoneConcernee",
            "conseil",
            "besoinInformationsSupplementaires",
            "questionsSupplementaires"
        }
        };
    }
    private static AiDiagnosticResult ValidateResult(
        AiDiagnosticResult result,
        string? userDescription)
    {
        result.QualiteImage =
            result.QualiteImage?.Trim() ?? string.Empty;

        result.ObservationVisible =
            result.ObservationVisible?.Trim() ?? string.Empty;

        result.ServiceTypeDetecte =
            NormalizeServiceType(result.ServiceTypeDetecte);

        result.Urgence =
            NormalizeUrgency(result.Urgence);

        result.ZoneConcernee =
            string.IsNullOrWhiteSpace(result.ZoneConcernee)
                ? "Non déterminée"
                : result.ZoneConcernee.Trim();

        result.Conseil =
            result.Conseil?.Trim() ?? string.Empty;

        result.QuestionsSupplementaires ??=
            new List<string>();

        result.QuestionsSupplementaires =
            result.QuestionsSupplementaires
                .Where(question =>
                    !string.IsNullOrWhiteSpace(question))
                .Select(question => question.Trim())
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(3)
                .ToList();

        result.Confiance =
            Math.Clamp(result.Confiance, 0, 1);

        /*
         * Cas 1 : l’image n’est pas exploitable.
         */
        if (!result.ImageValide ||
            !result.VehiculeDetecte)
        {
            result.ImageValide = false;
            result.ServiceTypeDetecte = string.Empty;
            result.DiagnosticCertain = false;
            result.BesoinInformationsSupplementaires = true;
            result.Urgence = "Non déterminée";
            result.ZoneConcernee = "Non déterminée";

            result.ObservationVisible =
                "La photo ne permet pas d’effectuer " +
                "une analyse automobile fiable.";

            result.Conseil =
                "Veuillez envoyer une photo automobile " +
                "plus claire et mieux cadrée.";

            result.QuestionsSupplementaires.Clear();

            return result;
        }

        /*
         * Cas 2 : aucun service n’a été proposé.
         *
         * On conserve l’observation et la zone.
         * On ne les efface plus.
         */
        if (string.IsNullOrWhiteSpace(
                result.ServiceTypeDetecte))
        {
            result.DiagnosticCertain = false;
            result.BesoinInformationsSupplementaires = true;

            if (string.IsNullOrWhiteSpace(
                    result.Conseil))
            {
                result.Conseil =
                    "Le problème est visible, mais aucun service " +
                    "disponible ne correspond avec suffisamment " +
                    "de précision.";
            }

            EnsureDefaultQuestions(result);

            return result;
        }

        /*
         * Cas 3 : un service a été proposé.
         *
         * On ne le supprime pas seulement parce que
         * diagnosticCertain est false.
         */
        result.BesoinInformationsSupplementaires =
            !result.DiagnosticCertain;

        /*
         * Sécurité supplémentaire :
         * sans description utilisateur, Entretien périodique
         * et Climatisation ne doivent pas être déduits
         * uniquement à partir d’une photo extérieure.
         */
        bool hasDescription =
            !string.IsNullOrWhiteSpace(userDescription);

        if (!hasDescription &&
            (result.ServiceTypeDetecte ==
                 "Entretien périodique" ||
             result.ServiceTypeDetecte ==
                 "Climatisation"))
        {
            result.ServiceTypeDetecte =
                string.Empty;

            result.DiagnosticCertain = false;
            result.BesoinInformationsSupplementaires = true;
            result.Urgence = "Non déterminée";

            result.Conseil =
                "Veuillez décrire précisément " +
                "le problème rencontré.";

            EnsureDefaultQuestions(result);

            return result;
        }

        /*
         * Si un service est valide, on conserve le résultat.
         */
        if (result.DiagnosticCertain)
        {
            result.BesoinInformationsSupplementaires =
                false;

            result.QuestionsSupplementaires.Clear();
        }
        else
        {
            EnsureDefaultQuestions(result);
        }

        return result;
    }
    private static void EnsureDefaultQuestions(
        AiDiagnosticResult result)
    {
        if (result.QuestionsSupplementaires.Count > 0)
        {
            return;
        }

        result.QuestionsSupplementaires = new List<string>
        {
            "Quelle partie du véhicule présente le problème ?",
            "Quel comportement anormal avez-vous remarqué ?",
            "Un message ou un voyant est-il réellement visible ?"
        };
    }

    private static string NormalizeServiceType(string? serviceType)
    {
        if (string.IsNullOrWhiteSpace(serviceType))
        {
            return string.Empty;
        }

        string value = serviceType.Trim();

        return AllowedServices.FirstOrDefault(
                   service => service.Equals(
                       value,
                       StringComparison.OrdinalIgnoreCase
                   )
               ) ?? string.Empty;
    }

    private static string NormalizeUrgency(string? urgency)
    {
        if (string.IsNullOrWhiteSpace(urgency))
        {
            return "Non déterminée";
        }

        string value = urgency.Trim().ToLowerInvariant();

        if (value.Contains("élev") ||
            value.Contains("eleve") ||
            value.Contains("critique") ||
            value.Contains("urgent"))
        {
            return "Élevée";
        }

        if (value.Contains("moy") ||
            value.Contains("modér") ||
            value.Contains("moder"))
        {
            return "Moyenne";
        }

        if (value.Contains("faible") ||
            value.Contains("basse"))
        {
            return "Faible";
        }

        return "Non déterminée";
    }
}
