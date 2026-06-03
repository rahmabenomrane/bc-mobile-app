
namespace StaBackend.Models
{
    public class AgencyDto
    {
        public string Name { get; set; } = "";
        public string Code { get; set; } = "";
        public string Address { get; set; } = "";
        public string PhoneNo { get; set; } = "";
        public string Email { get; set; } = "";
        public int Capacity { get; set; }
        public string OfficeHours { get; set; } = "";
    }

    public class BcAgencyResponse
    {
        public List<AgencyDto> value { get; set; } = new();
    }
}