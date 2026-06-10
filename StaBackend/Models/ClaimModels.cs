namespace ClaimsApi.Models;

public enum ClaimStatus
{
    InProgress = 0,
    Resolved = 1,
    Closed = 2,
    Cancelled = 3
}

public enum ClaimPriority
{
    Low = 0,
    Medium = 1,
    High = 2
}

// DTO reçu depuis Flutter (POST /api/claims)
public class CreateClaimRequest
{
    public string CustomerNo { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public ClaimPriority Priority { get; set; } = ClaimPriority.Medium;
    public string AppointmentRef { get; set; } = string.Empty; // référence RDV, pour log/traçabilité
}

// DTO renvoyé à Flutter
public class ClaimResponse
{
    public int ClaimNumber { get; set; }
    public DateTime CreationDate { get; set; }
    public string CustomerNo { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public ClaimStatus Status { get; set; }
    public ClaimPriority Priority { get; set; }
}

// DTO pour mise à jour statut
public class UpdateClaimStatusRequest
{
    public ClaimStatus Status { get; set; }
}

// Réponse OData BC (liste)
public class BcODataResponse<T>
{
    [System.Text.Json.Serialization.JsonPropertyName("value")]
    public List<T> Value { get; set; } = new();
}

// Payload BC (format OData)
public class BcClaim
{
    [System.Text.Json.Serialization.JsonPropertyName("claimNumber")]
    public int? ClaimNumber { get; set; }

    [System.Text.Json.Serialization.JsonPropertyName("creationDate")]
    public string CreationDate { get; set; } = string.Empty;

    [System.Text.Json.Serialization.JsonPropertyName("customerNo")]
    public string CustomerNo { get; set; } = string.Empty;

    [System.Text.Json.Serialization.JsonPropertyName("vehicleNo")]
    public string VehicleNo { get; set; } = string.Empty;

    [System.Text.Json.Serialization.JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [System.Text.Json.Serialization.JsonPropertyName("status")]
    public int Status { get; set; }

    [System.Text.Json.Serialization.JsonPropertyName("priority")]
    public int Priority { get; set; }
}