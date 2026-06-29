public class ClaimInfo
{
    public int ClaimNumber { get; set; }
    public string CreationDate { get; set; } = string.Empty;
    public string CustomerNo { get; set; } = string.Empty;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Status { get; set; }   // 0=InProgress 1=Resolved 2=Closed 3=Cancelled
    public int Priority { get; set; }   // 0=Low 1=Medium 2=High
}

public class CreateClaimRequest
{
    public string CustomerNo { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Priority { get; set; } = 1;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string AppointmentRef { get; set; } = string.Empty; 
}

public class CreateClaimResponse
{
    public bool Success { get; set; }
    public string? Error { get; set; }
    public int ClaimNumber { get; set; }
    public string CustomerNo { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Status { get; set; }
    public int Priority { get; set; }
}