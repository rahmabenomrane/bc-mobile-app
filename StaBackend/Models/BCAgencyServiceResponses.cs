
namespace StaBackend.Models
{
    public class BcServiceResponse
    {
        public List<BCServiceModel> value { get; set; }
            = new List<BCServiceModel>();
    }

    public class BcAgencyServiceResponse
    {
        public List<BCAgencyService> value { get; set; }
    }
}