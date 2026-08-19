public class ClaimInfo
{
    public string ClaimNumber { get; set; }
    public string CreationDate { get; set; } = string.Empty;
    public string CustomerNo { get; set; } = string.Empty;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Status { get; set; }   
    public int Priority { get; set; }   // 0=Low 1=Medium 2=High
    public string ServiceName { get; set; } = string.Empty;
    public string AgencyName { get; set; } = string.Empty;
    public string AppointmentRef { get; set; } = string.Empty;
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
    public string ClaimNumber { get; set; }
    public string CustomerNo { get; set; } = string.Empty;
    public string VehicleNo { get; set; } = string.Empty;
    public string RegistrationNumber { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Status { get; set; }
    public int Priority { get; set; }
}