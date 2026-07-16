using StaBackend.Config;
using StaBackend.Models;
using Microsoft.Extensions.Options;
using System.Net;
using System.Text;
using System.Text.Json;

namespace StaBackend.Services
{
    public class BcService : IBcService
    {
        private readonly BcSettings _config;

        private const string ODataBase = "http://localhost:7048/BC260/ODataV4/Company('STA')";

        public BcService(IOptions<BcSettings> config)
        {
            _config = config.Value;
        }

        // ── HttpClient avec Windows Auth ───────────────────────────
        private HttpClient CreateWindowsAuthClient()
        {
            var handler = new HttpClientHandler
            {
                Credentials = new NetworkCredential(
                    _config.WindowsUser,
                    _config.WindowsPassword,
                    ""
                ),
                PreAuthenticate = true,
                UseDefaultCredentials = false,
            };

            return new HttpClient(handler)
            {
                Timeout = TimeSpan.FromSeconds(60)
            };
        }

        // ── LOGIN ──────────────────────────────────────────────────
        public async Task<LoginResponse> LoginAsync(string phone, string password)
        {
            var client = CreateWindowsAuthClient();


            var url = "http://localhost:7048/BC260/api/monApp/auth/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/sessions";

            var bodyJson = JsonSerializer.Serialize(new
            {
                phone = phone,
                password = password
            });

            var bodyContent = new StringContent(bodyJson, Encoding.UTF8, "application/json");

            try
            {
                var response = await client.PostAsync(url, bodyContent);
                var content = await response.Content.ReadAsStringAsync();


                if (!response.IsSuccessStatusCode)
                {
                    try
                    {
                        var errJson = JsonDocument.Parse(content);
                        var errMsg = errJson.RootElement
                            .GetProperty("error")
                            .GetProperty("message")
                            .GetString();
                        return new LoginResponse { Success = false, Error = errMsg };
                    }
                    catch
                    {
                        return new LoginResponse { Success = false, Error = $"BC {response.StatusCode}: {content}" };
                    }
                }

                var json = JsonDocument.Parse(content);

                JsonElement root;
                if (json.RootElement.TryGetProperty("value", out var valueEl) &&
                    valueEl.ValueKind == JsonValueKind.Object)
                {
                    root = valueEl;
                }
                else
                {
                    root = json.RootElement;
                }

                var token = root.TryGetProperty("token", out var t) ? t.GetString() ?? "" : "";
                var customerNumber = root.TryGetProperty("customerNumber", out var cn) ? cn.GetString() ?? "" : "";
                var expiresAt = root.TryGetProperty("expiresAt", out var ea) ? ea.GetString() ?? "" : "";

                Console.WriteLine($"[LOGIN] customerNumber extrait : {customerNumber}");

                if (string.IsNullOrEmpty(customerNumber))
                {
                    foreach (var prop in root.EnumerateObject())
                        Console.WriteLine($"  → {prop.Name} = {prop.Value}");
                }

                return new LoginResponse
                {
                    Success = true,
                    Token = token,
                    ExpiresAt = expiresAt,
                    CustomerNumber = customerNumber
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[LOGIN] ❌ Exception : {ex}");
                return new LoginResponse { Success = false, Error = ex.Message };
            }
        }
        public async Task<string?> GetCustomerEmailAsync(string customerNumber)
        {
            var client = CreateWindowsAuthClient();
            var url = $"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/customers?$filter=numCustomer eq '{customerNumber}'";

            var response = await client.GetAsync(url);
            var json = await response.Content.ReadAsStringAsync();

            Console.WriteLine("GET CUSTOMER EMAIL = " + json);

            var doc = JsonDocument.Parse(json);
            if (doc.RootElement.TryGetProperty("value", out var values) &&
                values.GetArrayLength() > 0)
            {
                var first = values[0];
                return first.TryGetProperty("email", out var email)
                    ? email.GetString()
                    : null;
            }
            return null;
        }

        public async Task ConfirmAppointmentAsync(string appointmentNo)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI('{appointmentNo}')";

            var getResponse = await client.GetAsync(url);
            var getJson = await getResponse.Content.ReadAsStringAsync();
            var etag = JsonDocument.Parse(getJson)
                .RootElement.GetProperty("@odata.etag").GetString();

            // PATCH status = Confirmed
            var body = new { status = "Confirmed" };
            var content = new StringContent(
                JsonSerializer.Serialize(body), Encoding.UTF8, "application/json");

            var request = new HttpRequestMessage(HttpMethod.Patch, url) { Content = content };
            request.Headers.Add("If-Match", etag);

            var response = await client.SendAsync(request);
            var responseText = await response.Content.ReadAsStringAsync();

            Console.WriteLine("CONFIRM BC RESPONSE: " + responseText);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"BC error: {responseText}");
        }


        // ── GET CUSTOMER BY NUMBER ───────────────────────────────────────────
        public async Task<CustomerInfo?> GetCustomerByNumberAsync(string customerNumber)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaCustomerAPI('{customerNumber}')";

            Console.WriteLine($"[GET CUSTOMER] GET → {url}");

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[GET CUSTOMER] ❌ Error: {content}");
                    return null;
                }

                var json = JsonDocument.Parse(content);
                JsonElement root;

                if (json.RootElement.TryGetProperty("value", out var valueEl))
                    root = valueEl;
                else
                    root = json.RootElement;

                return new CustomerInfo
                {
                    NumCustomer = root.TryGetProperty("numCustomer", out var nc) ? nc.GetString() ?? "" : "",
                    Name = root.TryGetProperty("lastName", out var ln) ? ln.GetString() ?? "" : "",
                    FirstName = root.TryGetProperty("firstName", out var fn) ? fn.GetString() ?? "" : "",
                    Address = root.TryGetProperty("address", out var addr) ? addr.GetString() ?? "" : "",
                    Phone = root.TryGetProperty("phone", out var ph) ? ph.GetString() ?? "" : "",
                    Email = root.TryGetProperty("email", out var em) ? em.GetString() ?? "" : "",
                    Civility = root.TryGetProperty("civility", out var civ) ? civ.GetString() ?? "" : "",
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET CUSTOMER] ❌ Exception: {ex.Message}");
                return null;
            }
        }

        public async Task<UpdateProfileResponse> ChangePasswordAsync(
       string customerNumber, string currentPassword, string newPassword)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaChangePasswordAPI('{customerNumber}')";


            var getRequest = new HttpRequestMessage(HttpMethod.Get, url);
            var getResponse = await client.SendAsync(getRequest);
            var getContent = await getResponse.Content.ReadAsStringAsync();

            if (!getResponse.IsSuccessStatusCode)
                return new UpdateProfileResponse { Success = false, Error = $"GET failed: {getContent}" };


            var getJson = JsonDocument.Parse(getContent);
            var etag = getJson.RootElement
                .GetProperty("@odata.etag")
                .GetString();

            if (string.IsNullOrEmpty(etag))
                return new UpdateProfileResponse { Success = false, Error = "No ETag in BC response body" };


            var body = new
            {
                customerNumber = customerNumber,
                currentPassword = currentPassword,
                newPassword = newPassword
            };

            var json = JsonSerializer.Serialize(body);

            var patchRequest = new HttpRequestMessage(HttpMethod.Patch, url)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };

            patchRequest.Headers.Add("If-Match", etag);

            var response = await client.SendAsync(patchRequest);
            var content = await response.Content.ReadAsStringAsync();

            return new UpdateProfileResponse
            {
                Success = response.IsSuccessStatusCode,
                Error = content
            };
        }
        public async Task<UpdateProfileResponse> UpdateCustomerProfileAsync(string customerNumber, UpdateProfileRequest request)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaCustomerAPI('{customerNumber}')";

            var updateData = new Dictionary<string, object>();

            if (!string.IsNullOrEmpty(request.LastName))
                updateData["lastName"] = request.LastName;

            if (!string.IsNullOrEmpty(request.FirstName))
                updateData["firstName"] = request.FirstName;

            if (!string.IsNullOrEmpty(request.Address))
                updateData["address"] = request.Address;

            if (!string.IsNullOrEmpty(request.Phone))
                updateData["phone"] = request.Phone;

            if (!string.IsNullOrEmpty(request.Email))
                updateData["email"] = request.Email;

            if (!string.IsNullOrEmpty(request.Civility))
                updateData["civility"] = request.Civility;

            if (updateData.Count == 0)
                return new UpdateProfileResponse { Success = false, Error = "No fields to update" };

            var bodyJson = JsonSerializer.Serialize(updateData);
            var bodyContent = new StringContent(bodyJson, Encoding.UTF8, "application/json");


            try
            {
                var httpRequest = new HttpRequestMessage(HttpMethod.Patch, url)
                {
                    Content = bodyContent
                };
                httpRequest.Headers.TryAddWithoutValidation("If-Match", "*");

                var response = await client.SendAsync(httpRequest);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var error = ExtractError(content);
                    return new UpdateProfileResponse { Success = false, Error = error };
                }

                return new UpdateProfileResponse { Success = true };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UPDATE PROFILE] ❌ Exception: {ex.Message}");
                return new UpdateProfileResponse { Success = false, Error = ex.Message };
            }
        }

        // ── GET CLAIMS ──────────────────────────────────────────────────
        public async Task<List<ClaimInfo>> GetClaimsAsync(string customerNumber)
        {
            var client = CreateWindowsAuthClient();
            var url = $"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/Claims?$filter=customerNo eq '{customerNumber}'";

            Console.WriteLine($"[GET CLAIMS] GET → {url}");

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[GET CLAIMS] ❌ Error: {content}");
                    return new List<ClaimInfo>();
                }

                var doc = JsonDocument.Parse(content);
                if (!doc.RootElement.TryGetProperty("value", out var values))
                    return new List<ClaimInfo>();

                var result = new List<ClaimInfo>();
                foreach (var item in values.EnumerateArray())
                {
                    var claim = new ClaimInfo
                    {
                        ClaimNumber = item.TryGetProperty("claimNumber", out var cn) ? cn.GetInt32() : 0,
                        CreationDate = item.TryGetProperty("creationDate", out var cd) ? cd.GetString() ?? "" : "",
                        CustomerNo = item.TryGetProperty("customerNo", out var cno) ? cno.GetString() ?? "" : "",
                        VehicleNo = item.TryGetProperty("vehicleNo", out var vn) ? vn.GetString() ?? "" : "",
                        Description = item.TryGetProperty("description", out var desc) ? desc.GetString() ?? "" : "",
                        RegistrationNumber = item.TryGetProperty("registrationNumber", out var rn) ? rn.GetString() ?? "" : "",
                        Status = ParseStatusFromBc(item.TryGetProperty("status", out var st) ? st.GetString() ?? "" : ""),
                        Priority = ParsePriorityFromBc(item.TryGetProperty("priority", out var pr) ? pr.GetString() ?? "" : ""),
                        // Récupérer l'appointmentRef si disponible
                        AppointmentRef = item.TryGetProperty("appointmentRef", out var ar) ? ar.GetString() ?? "" : "",
                    };

                    // Si la réclamation a un rendez-vous, récupérer les détails
                    if (!string.IsNullOrEmpty(claim.AppointmentRef))
                    {
                        try
                        {
                            var appointmentDetails = await GetAppointmentDetails(claim.AppointmentRef);
                            claim.ServiceName = appointmentDetails.ServiceName;
                            claim.AgencyName = appointmentDetails.AgencyName;
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[GET CLAIMS] Error fetching appointment: {ex.Message}");
                        }
                    }

                    result.Add(claim);
                }

                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET CLAIMS] ❌ Exception: {ex.Message}");
                return new List<ClaimInfo>();
            }
        }

        // Ajouter cette méthode pour récupérer les détails du rendez-vous
        private async Task<(string ServiceName, string AgencyName)> GetAppointmentDetails(string appointmentRef)
        {
            try
            {
                var client = CreateWindowsAuthClient();
                var url = $"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/Appointments?$filter=appointmentNo eq '{appointmentRef}'";

                var response = await client.GetAsync(url);
                if (!response.IsSuccessStatusCode)
                    return ("", "");

                var content = await response.Content.ReadAsStringAsync();
                var doc = JsonDocument.Parse(content);

                if (!doc.RootElement.TryGetProperty("value", out var values) || values.GetArrayLength() == 0)
                    return ("", "");

                var appointment = values.EnumerateArray().First();

                string serviceName = "";
                if (appointment.TryGetProperty("serviceDescription", out var sd))
                    serviceName = sd.GetString() ?? "";
                else if (appointment.TryGetProperty("serviceName", out var sn))
                    serviceName = sn.GetString() ?? "";

                string agencyName = "";
                if (appointment.TryGetProperty("agencyName", out var an))
                    agencyName = an.GetString() ?? "";
                else if (appointment.TryGetProperty("AgencyName", out var an2))
                    agencyName = an2.GetString() ?? "";

                return (serviceName, agencyName);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET APPOINTMENT] Error: {ex.Message}");
                return ("", "");
            }
        }
        // ── CREATE CLAIM ────────────────────────────────────────────────
        public async Task<CreateClaimResponse> CreateClaimAsync(CreateClaimRequest request)
        {
            var client = CreateWindowsAuthClient();
            var url = $"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/Claims";

            var bodyJson = JsonSerializer.Serialize(new
            {
                creationDate = DateTime.Today.ToString("yyyy-MM-dd"),
                customerNo = request.CustomerNo,
                vehicleNo = request.VehicleNo,
                description = request.Description,
                registrationNumber = request.RegistrationNumber,
                status = "In Progress",
                priority = MapPriorityToBc(request.Priority),
            });

            try
            {
                var response = await client.PostAsync(
                    url, new StringContent(bodyJson, Encoding.UTF8, "application/json"));
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    try
                    {
                        var errMsg = JsonDocument.Parse(content)
                            .RootElement.GetProperty("error")
                            .GetProperty("message").GetString();
                        return new CreateClaimResponse { Success = false, Error = errMsg };
                    }
                    catch
                    {
                        return new CreateClaimResponse { Success = false, Error = $"BC {response.StatusCode}: {content}" };
                    }
                }

                var root = JsonDocument.Parse(content).RootElement;
                if (root.TryGetProperty("value", out var v) && v.ValueKind == JsonValueKind.Object)
                    root = v;

                return new CreateClaimResponse
                {
                    Success = true,
                    ClaimNumber = root.TryGetProperty("claimNumber", out var nr) ? nr.GetInt32() : 0,
                    CustomerNo = root.TryGetProperty("customerNo", out var cno) ? cno.GetString() ?? "" : "",
                    VehicleNo = root.TryGetProperty("vehicleNo", out var vno) ? vno.GetString() ?? "" : "",
                    Description = root.TryGetProperty("description", out var desc) ? desc.GetString() ?? "" : "",
                    Status = ParseStatusFromBc(root.TryGetProperty("status", out var st) ? st.GetString() ?? "" : ""),
                    RegistrationNumber = root.TryGetProperty("registrationNumber", out var rn) ? rn.GetString() ?? "" : "",
                    Priority = ParsePriorityFromBc(root.TryGetProperty("priority", out var pr) ? pr.GetString() ?? "" : ""),
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CREATE CLAIM] ❌ Exception: {ex.Message}");
                return new CreateClaimResponse { Success = false, Error = ex.Message };
            }
        }

        // ── UPDATE STATUS ───────────────────────────────────────────────
        public async Task UpdateClaimStatusAsync(int claimNumber, int newStatus)
        {
            var client = CreateWindowsAuthClient();
            var url = $"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)/Claims({claimNumber})";

            var getResponse = await client.GetAsync(url);
            var getJson = await getResponse.Content.ReadAsStringAsync();

            string? etag = null;
            try { etag = JsonDocument.Parse(getJson).RootElement.GetProperty("@odata.etag").GetString(); }
            catch { Console.WriteLine("[UPDATE CLAIM] ⚠️ ETag introuvable, utilisation de *"); }

            var bodyJson = JsonSerializer.Serialize(new { status = MapStatusToBc(newStatus) });
            var patchRequest = new HttpRequestMessage(HttpMethod.Patch, url)
            {
                Content = new StringContent(bodyJson, Encoding.UTF8, "application/json")
            };
            patchRequest.Headers.Add("If-Match", etag ?? "*");

            var response = await client.SendAsync(patchRequest);
            var responseText = await response.Content.ReadAsStringAsync();

            Console.WriteLine($"[UPDATE CLAIM] {response.StatusCode} → {responseText}");

            if (!response.IsSuccessStatusCode)
                throw new Exception($"BC error {response.StatusCode}: {responseText}");
        }



        private static int ParseStatusFromBc(string s) => s.Replace("_x0020_", " ") switch
        {
            "In Progress" => 0,
            "Resolved" => 1,
            "Closed" => 2,
            "Cancelled" => 3,
            _ => 0
        };

        private static int ParsePriorityFromBc(string s) => s switch
        {
            "Low" => 0,
            "Medium" => 1,
            "High" => 2,
            _ => 1
        };

        private static string MapStatusToBc(int status) => status switch
        {
            0 => "In Progress",
            1 => "Resolved",
            2 => "Closed",
            3 => "Cancelled",
            _ => "In Progress"
        };

        private static string MapPriorityToBc(int priority) => priority switch
        {
            0 => "Low",
            1 => "Medium",
            2 => "High",
            _ => "Medium"
        };


        // ── CHECK PHONE UNIQUENESS ───────────────────────────────────────────
        public async Task<bool> IsPhoneUniqueAsync(string phone, string currentCustomerNumber)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaCustomerAPI?$filter=phone eq '{phone}' and numCustomer ne '{currentCustomerNumber}'";

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                    return true;

                var json = JsonDocument.Parse(content);
                if (json.RootElement.TryGetProperty("value", out var valueEl))
                {

                    return valueEl.GetArrayLength() == 0;
                }

                return true;
            }
            catch
            {
                return true;
            }
        }
        // cancel appointment
        public async Task CancelAppointmentAsync(string appointmentNo)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI('{appointmentNo}')";

            var getResponse = await client.GetAsync(url);
            var getJson = await getResponse.Content.ReadAsStringAsync();
            var etag = JsonDocument.Parse(getJson)
                .RootElement.GetProperty("@odata.etag").GetString();

            var body = new { status = "Cancelled" };
            var content = new StringContent(
                JsonSerializer.Serialize(body), Encoding.UTF8, "application/json");

            var request = new HttpRequestMessage(HttpMethod.Patch, url) { Content = content };
            request.Headers.Add("If-Match", etag);

            var response = await client.SendAsync(request);
            if (!response.IsSuccessStatusCode)
                throw new Exception(await response.Content.ReadAsStringAsync());
        }

        // ── CHECK EMAIL UNIQUENESS ───────────────────────────────────────────
        public async Task<bool> IsEmailUniqueAsync(string email, string currentCustomerNumber)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaCustomerAPI?$filter=email eq '{email}' and numCustomer ne '{currentCustomerNumber}'";

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                    return true;

                var json = JsonDocument.Parse(content);
                if (json.RootElement.TryGetProperty("value", out var valueEl))
                {
                    return valueEl.GetArrayLength() == 0;
                }

                return true;
            }
            catch
            {
                return true;
            }
        }

        private string ExtractError(string content)
        {
            try
            {
                var json = JsonDocument.Parse(content);
                if (json.RootElement.TryGetProperty("error", out var error))
                {
                    if (error.TryGetProperty("message", out var message))
                        return message.GetString() ?? "Unknown error";
                }
                return content;
            }
            catch
            {
                return content;
            }
        }

        // ── REGISTER ───────────────────────────────────────────────
        public async Task<RegisterResponse> RegisterAsync(RegisterRequest request)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaCustomerAPI";
            var getUrl = $"{ODataBase}/StaCustomerAPI?$top=1";
            var getResponse = await client.GetAsync(getUrl);
            var getContent = await getResponse.Content.ReadAsStringAsync();
            Console.WriteLine($"[REGISTER] Sample record from NAV: {getContent}");
            var bodyJson = JsonSerializer.Serialize(new
            {
                phone = request.Phone,
                email = request.Email,
                lastName = $"{request.FirstName} {request.LastName}".Trim(),
                address = request.Address,
                password = request.Password,
                civility = request.Civility
            });

            Console.WriteLine($"[REGISTER] POST → {url}");

            var bodyContent = new StringContent(bodyJson, Encoding.UTF8, "application/json");

            try
            {
                var response = await client.PostAsync(url, bodyContent);
                var content = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"[REGISTER] Status  → {response.StatusCode}");
                Console.WriteLine($"[REGISTER] Content → {content}");

                if (!response.IsSuccessStatusCode)
                {
                    try
                    {
                        var errJson = JsonDocument.Parse(content);
                        var errMsg = errJson.RootElement
                            .GetProperty("error")
                            .GetProperty("message")
                            .GetString();
                        return new RegisterResponse { Success = false, Error = errMsg };
                    }
                    catch
                    {
                        return new RegisterResponse { Success = false, Error = $"BC {response.StatusCode}: {content}" };
                    }
                }

                return new RegisterResponse { Success = true };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[REGISTER] ❌ Exception : {ex}");
                return new RegisterResponse { Success = false, Error = ex.Message };
            }
        }
        public async Task<bool> CreateVehicleAsync(CreateVehicleDto vehicle)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaVehicleAPI";


            var body = new
            {
                NumCustomer = vehicle.NumCustomer,
                makeCode = vehicle.MakeCode,
                modelCode = vehicle.ModelCode,
                motorisation = vehicle.Motorisation,
                registrationNumber = vehicle.RegistrationNumber,
                Mileage = vehicle.Mileage
            };

            var json = JsonSerializer.Serialize(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            Console.WriteLine($"[CREATE VEHICLE] POST → {url}");
            Console.WriteLine($"[CREATE VEHICLE] Body → {json}");

            var response = await client.PostAsync(url, content);
            var responseContent = await response.Content.ReadAsStringAsync();

            Console.WriteLine($"[CREATE VEHICLE] Status → {response.StatusCode}");
            Console.WriteLine($"[CREATE VEHICLE] Response → {responseContent}");

            return response.IsSuccessStatusCode;
        }
        private const string ApiBase =
"http://localhost:7048/BC260/api/STA/Mobile/v1.0/companies(16be2528-96e4-f011-8d1f-00155d141f04)";
        public async Task<List<MakeDto>> GetMakesAsync()
        {
            var client = CreateWindowsAuthClient();

            var url = $"{ApiBase}/makes";

            var response = await client.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            Console.WriteLine("STATUS get makes: " + response.StatusCode);
            Console.WriteLine("CONTENT:");
            Console.WriteLine(content);

            if (!response.IsSuccessStatusCode)
                return new List<MakeDto>();

            var result = JsonSerializer.Deserialize<BcMakeResponse>(
                content,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
            );

            return result?.Value?.Select(x => new MakeDto
            {
                Code = x.Code,
                Name = x.Name
            }).ToList() ?? new List<MakeDto>();
        }
        public async Task<List<ModelDto>> GetModelsByMakeAsync(string makeCode)
        {
            var client = CreateWindowsAuthClient();

            var url = $"{ApiBase}/models?$filter=makeCode eq '{makeCode}'";

            var response = await client.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            var result = JsonSerializer.Deserialize<BcModelResponse>(content,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return result?.Value?.Select(x => new ModelDto
            {
                Code = x.Code,
                MakeCode = x.MakeCode,
                Name = x.Name
            }).ToList() ?? new List<ModelDto>();
        }
        // ── GET VEHICLES ───────────────────────────────────────────
        public async Task<List<VehicleDto>> GetCustomerVehiclesAsync(string customerNum)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaVehicleAPI?$filter=numCustomer eq '{customerNum}'";

            Console.WriteLine($"[VEHICLES] GET → {url}");

            Console.WriteLine(url);
            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();
                Console.WriteLine("=== REPONSE BC ===");
                Console.WriteLine(content);
                Console.WriteLine($"[VEHICLES] Status  → {response.StatusCode}");
                Console.WriteLine($"Customer recherché = {customerNum}");
                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[VEHICLES] ❌ Erreur BC : {content}");
                    return new List<VehicleDto>();
                }

                var bcResponse = JsonSerializer.Deserialize<BcVehicleResponse>(
                    content,
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );

                var vehicles = bcResponse?.value?.Select(v => new VehicleDto
                {
                    Id = v.Id,
                    NumVehicle = v.NumVehicle,
                    NumCustomer = v.NumCustomer,
                    MakeCode = v.MakeCode,
                    ModelCode = v.ModelCode,
                    Motorisation = v.Motorisation,
                    RegistrationNumber = v.RegistrationNumber,
                    Mileage = v.Mileage

                }).ToList() ?? new List<VehicleDto>();

                Console.WriteLine($"[VEHICLES] {vehicles.Count} véhicule(s) pour client {customerNum}");
                return vehicles;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[VEHICLES] ❌ Exception : {ex.Message}");
                return new List<VehicleDto>();
            }
        }

        public async Task<List<AppointmentDto>> GetAppointmentsByDateAsync(DateTime date)
        {
            var client = CreateWindowsAuthClient();
            var dateStr = date.ToString("yyyy-MM-dd");
            var url = $"{ODataBase}/AppointmentAPI?$filter=Date eq '{dateStr}'";

            var response = await client.GetAsync(url);
            var json = await response.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<BcAppointmentRawResponse>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (data?.value == null) return new List<AppointmentDto>();

            return data.value.Select(raw =>
            {
                var d = DateTime.Parse(raw.Date);
                var start = TimeSpan.Parse(raw.StartTime);
                var end = TimeSpan.Parse(raw.EndTime);

                return new AppointmentDto
                {
                    AppointmentNo = raw.AppointmentNo,
                    AgencyCode = raw.AgencyCode,
                    AgencyName = raw.AgencyName,
                    ServiceCode = raw.ServiceCode,
                    ServiceDescription = raw.ServiceDescription,
                    Date = d,
                    StartTime = d.Add(start),
                    EndTime = d.Add(end),
                    Status = raw.Status,
                    NumVehicle = raw.NumVehicle,
                    PontId = raw.PontId,
                };
            }).ToList();
        }

        public async Task<VehicleDto?> GetVehicleByNumAsync(string numVehicle)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaVehicleAPI?$filter=numVehicle eq '{numVehicle}'";

            var response = await client.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            var bcResponse = JsonSerializer.Deserialize<BcVehicleResponse>(
                content,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return bcResponse?.value?.Select(v => new VehicleDto
            {
                NumVehicle = v.NumVehicle,
                NumCustomer = v.NumCustomer,
                RegistrationNumber = v.RegistrationNumber,
            }).FirstOrDefault();
        }
        public async Task<List<AppointmentDto>> GetCustomerAppointmentsAsync(string customerNumber)
        {
            var client = CreateWindowsAuthClient();

            var vehicles = await GetCustomerVehiclesAsync(customerNumber);
            var agencies = await GetAgenciesAsync();

            var vehicleNumbers = vehicles
                .Select(v => v.NumVehicle?.Trim().ToUpper())
                .ToList();

            var response = await client.GetAsync($"{ODataBase}/AppointmentAPI");
            var json = await response.Content.ReadAsStringAsync();
            var data = JsonSerializer.Deserialize<BcAppointmentRawResponse>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (data?.value == null) return new List<AppointmentDto>();
            foreach (var raw in data.value)
            {
                Console.WriteLine($"{raw.ServiceCode} -> {raw.ServiceDescription}");
            }
            return data.value
                .Where(raw => vehicleNumbers.Contains(raw.NumVehicle?.Trim().ToUpper()))
                .Select(raw =>
                {
                    var date = DateTime.Parse(raw.Date);
                    var start = TimeSpan.Parse(raw.StartTime);
                    var end = TimeSpan.Parse(raw.EndTime);

                    var vehicle = vehicles.FirstOrDefault(v =>
                        v.NumVehicle?.Trim().ToUpper() == raw.NumVehicle?.Trim().ToUpper());
                    var agence = agencies.FirstOrDefault(a =>
                        a.Code?.Trim().ToUpper() == raw.AgencyCode?.Trim().ToUpper());

                    return new AppointmentDto
                    {
                        AppointmentNo = raw.AppointmentNo,
                        AgencyCode = raw.AgencyCode,
                        AgencyName = agence?.Name,
                        ServiceCode = raw.ServiceCode,
                        ServiceDescription = raw.ServiceDescription,
                        Date = date,
                        StartTime = date.Add(start),
                        EndTime = date.Add(end),
                        Status = raw.Status,
                        NumVehicle = raw.NumVehicle,
                        PontId = raw.PontId,
                        RegistrationNumber = vehicle?.RegistrationNumber,
                        Mileage = vehicle?.Mileage,
                    };
                }).ToList();
        }
        public async Task<CreateAppointmentResponse> CreateAppointmentAsync(CreateAppointmentDto dto)
        {
            var existing = await GetAppointmentsAsync(dto.AgencyCode, dto.ServiceCode);

            Console.WriteLine($"Existing count = {existing.Count}");
            foreach (var a in existing)
                Console.WriteLine($"  → NumVehicle={a.NumVehicle} Status={a.Status}");
            var now = DateTime.Now;

            var futureAppointments = (await GetAppointmentsAsync(dto.AgencyCode, dto.ServiceCode))
                .Where(a => a.StartTime > now &&
                            !string.Equals(a.Status, "Cancelled", StringComparison.OrdinalIgnoreCase))
                .ToList();

            var vehicleConflict = futureAppointments.Any(a =>
                string.Equals(a.NumVehicle?.Trim(), dto.VehicleNumber?.Trim(), StringComparison.OrdinalIgnoreCase)
                && string.Equals(a.ServiceCode?.Trim(), dto.ServiceCode?.Trim(), StringComparison.OrdinalIgnoreCase));
            Console.WriteLine($"VehicleNumber={dto.VehicleNumber} vehicleConflict={vehicleConflict}");

            Console.WriteLine($"VehicleNumber={dto.VehicleNumber} vehicleConflict={vehicleConflict}");

            if (vehicleConflict)
                throw new Exception("Ce véhicule a déjà un rendez-vous pour ce service.");

            // — trouver un pont libre
            var allPonts = await GetCarLiftsAsync(dto.AgencyCode);
            string assignedPontId;

            if (allPonts.Count == 0)
            {
                assignedPontId = "AUTO";
            }
            else
            {
                var allAppointments = await GetAllAppointmentsForAgencyAsync(dto.AgencyCode);

                var availablePont = allPonts
                    .Where(p => p.Active)
                    .FirstOrDefault(p => !allAppointments.Any(a =>
                        a.PontId == p.Code &&
                        a.StartTime.Date == dto.Date.Date &&
                        a.StartTime.Hour == dto.StartTime &&
                        a.Status != "Cancelled"));

                if (availablePont == null)
                    throw new Exception("Aucun pont disponible à ce créneau.");

                assignedPontId = availablePont.Code;
                Console.WriteLine($"✅ Pont assigné = {assignedPontId}");
            }


            var appointment = new AppointmentDto
            {
                AgencyCode = dto.AgencyCode,
                ServiceCode = dto.ServiceCode,
                ServiceDescription = dto.ServiceDescription,
                Date = dto.Date,
                StartTime = new DateTime(dto.Date.Year, dto.Date.Month, dto.Date.Day, dto.StartTime, 0, 0),
                EndTime = new DateTime(dto.Date.Year, dto.Date.Month, dto.Date.Day, dto.EndTime + 1, 0, 0),
                Status = "Pending",
                AppointmentNo = "RDV-" + DateTime.Now.Ticks.ToString()[..12],
                NumVehicle = dto.VehicleNumber,
                PontId = assignedPontId,
            };

            await SaveAppointment(appointment);

            return new CreateAppointmentResponse { Success = true, Message = "Created", Data = appointment };
        }
        public async Task<List<CarLiftDto>> GetCarLiftsAsync(string agencyCode)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/CarLiftAPI?$filter=agencyCode eq '{agencyCode}'";

            Console.WriteLine($"GET CARLIFTS = {url}");

            var response = await client.GetAsync(url);
            var json = await response.Content.ReadAsStringAsync();

            Console.WriteLine($"CARLIFTS JSON = {json}");

            var data = JsonSerializer.Deserialize<BcCarLiftResponse>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return data?.value ?? new List<CarLiftDto>();
        }

        public async Task<List<AppointmentDto>> GetAllAppointmentsForAgencyAsync(string agencyCode)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI?$filter=AgencyCode eq '{agencyCode}'";

            var response = await client.GetAsync(url);
            var json = await response.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<BcAppointmentRawResponse>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (data?.value == null) return new List<AppointmentDto>();

            return data.value.Select(raw =>
            {
                var date = DateTime.Parse(raw.Date);
                var start = TimeSpan.Parse(raw.StartTime);
                var end = TimeSpan.Parse(raw.EndTime);

                return new AppointmentDto
                {
                    AppointmentNo = raw.AppointmentNo,
                    AgencyCode = raw.AgencyCode,
                    ServiceCode = raw.ServiceCode,
                    Date = date,
                    StartTime = date.Add(start),
                    EndTime = date.Add(end),
                    Status = raw.Status,
                    NumVehicle = raw.NumVehicle,
                    PontId = raw.PontId,
                };
            }).ToList();
        }


        private class BcCarLiftResponse
        {
            public List<CarLiftDto> value { get; set; }
        }
        public async Task<bool> RescheduleAppointmentAsync(RescheduleAppointmentDto dto)
        {

            var client = CreateWindowsAuthClient();
            var getResponse = await client.GetAsync($"{ODataBase}/AppointmentAPI('{dto.AppointmentNo}')");
            var getJson = await getResponse.Content.ReadAsStringAsync();
            var jsonDoc = JsonDocument.Parse(getJson);

            var etag = jsonDoc.RootElement.GetProperty("@odata.etag").GetString();
            var agencyCode = jsonDoc.RootElement.GetProperty("AgencyCode").GetString();
            var serviceCode = jsonDoc.RootElement.GetProperty("ServiceCode").GetString();

            var existing = await GetAppointmentsAsync(agencyCode, serviceCode);
            var conflict = existing.Any(a =>
                a.AppointmentNo != dto.AppointmentNo &&
                a.StartTime.Date == dto.Date.Date &&
                a.StartTime.Hour == dto.StartTime);

            if (conflict)
                throw new Exception("Ce créneau est déjà pris.");

            // PATCH
            var body = new
            {
                date = dto.Date.ToString("yyyy-MM-dd"),
                startTime = $"{dto.StartTime:D2}:00:00",
                endTime = $"{dto.EndTime:D2}:00:00",
            };

            var json = JsonSerializer.Serialize(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            var request = new HttpRequestMessage(HttpMethod.Patch, $"{ODataBase}/AppointmentAPI('{dto.AppointmentNo}')")
            {
                Content = content
            };
            request.Headers.Add("If-Match", etag);

            var response = await client.SendAsync(request);
            var responseText = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode) return true;
            throw new Exception($"BC error: {responseText}");
        }
        // ── LOGOUT ────────────────────────────────────────────────
        public async Task LogoutAsync(string token)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaSessionAPI/Microsoft.NAV.Logout";

            var bodyJson = JsonSerializer.Serialize(new { Token = token });
            var bodyContent = new StringContent(bodyJson, Encoding.UTF8, "application/json");

            Console.WriteLine($"[LOGOUT] POST → {url}");
            await client.PostAsync(url, bodyContent);
        }
        private class BcServicesResponse
        {
            public List<BcServiceRaw> value { get; set; }
        }

        private class BcServiceRaw
        {
            public string ServiceCode { get; set; }
            public string Description { get; set; }
            public string Libelle { get; set; }
            public string Type { get; set; }
        }


        private string GetServiceType(string type)
        {
            return type?.ToLower() switch
            {
                "Entretien periodique" => "Entretien periodique",
                "diagnostic" => "diagnostic",
                "pneumatique" => "pneumatique",
                "climatisation" => "climatisation",
                "revision" => "revision",
                _ => ""
            };
        }
        public async Task<List<ServiceDto>> GetServicesByAgencyAsync(string agencyCode)
        {
            var client = CreateWindowsAuthClient();


            var agencyServiceUrl = $"{ODataBase}/AgencyServiceAPI";
            var response = await client.GetAsync(agencyServiceUrl);
            var content = await response.Content.ReadAsStringAsync();
            Console.WriteLine($"AgencyService JSON = {content}");
            var bcAgencyServices = JsonSerializer.Deserialize<BcAgencyServiceResponse>(
                content,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (bcAgencyServices?.value == null)
                return new List<ServiceDto>();

            var agencyServiceCodes = bcAgencyServices.value
                .Where(a =>
                    !string.IsNullOrWhiteSpace(a.agencyCode) &&
                    !string.IsNullOrWhiteSpace(a.serviceCode) &&
                    a.agencyCode.Trim().Equals(agencyCode.Trim(), StringComparison.OrdinalIgnoreCase) &&
                    a.Disponible == true)
                .Select(a => a.serviceCode?.Trim())
                .ToList();

            if (!agencyServiceCodes.Any())
                return new List<ServiceDto>();

            //  Récupérer les détails depuis ServicesAPI
            var servicesUrl = $"{ODataBase}/ServicesAPI";
            var servicesResponse = await client.GetAsync(servicesUrl);
            var servicesContent = await servicesResponse.Content.ReadAsStringAsync();

            Console.WriteLine($"SERVICES JSON = {servicesContent}");

            var bcServices = JsonSerializer.Deserialize<BcServicesResponse>(
                servicesContent,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (bcServices?.value == null)
                return new List<ServiceDto>();
            Console.WriteLine($"SERVICES URL = {servicesUrl}");
            Console.WriteLine($"SERVICES STATUS = {servicesResponse.StatusCode}");
            Console.WriteLine($"SERVICES JSON = {servicesContent}");
            Console.WriteLine($"agencyServiceCodes = {string.Join(", ", agencyServiceCodes)}");


            return bcServices.value
                .Where(s => agencyServiceCodes.Any(code =>
                    s.Libelle?.Trim().ToUpper() == code.Trim().ToUpper() ||
                    s.Description?.Trim().ToUpper() == code.Trim().ToUpper() ||
                    s.ServiceCode?.Trim().ToUpper() == code.Trim().ToUpper()
                ))
                .Select(s => new ServiceDto
                {
                    Code = s.ServiceCode?.Trim(),
                    Name = s.Libelle?.Trim() ?? s.Description?.Trim() ?? s.ServiceCode,
                    Description = s.Description?.Trim() ?? "",
                    Type = GetServiceType(s.Type),
                    Duration = "1h"
                })
                .ToList();
        }


        private class BcAppointmentRaw
        {
            public string AppointmentNo { get; set; }
            public string AgencyCode { get; set; }
            public string AgencyName { get; set; }
            public string ServiceDescription { get; set; }
            public string ServiceCode { get; set; }
            public string Date { get; set; }
            public string StartTime { get; set; }
            public string EndTime { get; set; }
            public string Status { get; set; }
            public string NumVehicle { get; set; }
            public string PontId { get; set; }
        }

        private class BcAppointmentRawResponse
        {
            public List<BcAppointmentRaw> value { get; set; }
        }

        public async Task<List<AppointmentDto>> GetAppointmentsAsync(string agencyCode, string serviceCode)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI?$filter=AgencyCode eq '{agencyCode}' and ServiceCode eq '{serviceCode}'";

            var response = await client.GetAsync(url);
            var json = await response.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<BcAppointmentRawResponse>(
                json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (data?.value == null) return new List<AppointmentDto>();

            return data.value.Select(raw =>
            {
                var date = DateTime.Parse(raw.Date);
                var start = TimeSpan.Parse(raw.StartTime);
                var end = TimeSpan.Parse(raw.EndTime);

                return new AppointmentDto
                {
                    AppointmentNo = raw.AppointmentNo,
                    AgencyCode = raw.AgencyCode,
                    AgencyName = raw.AgencyName,
                    ServiceCode = raw.ServiceCode,
                    ServiceDescription = raw.ServiceDescription,
                    Date = date,
                    StartTime = date.Add(start),
                    EndTime = date.Add(end),
                    Status = raw.Status,
                    NumVehicle = raw.NumVehicle,
                    PontId = raw.PontId,
                };
            }).ToList();
        }
        private async Task SaveAppointment(AppointmentDto appointment)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI";

            var body = new
            {
                agencyCode = appointment.AgencyCode,
                serviceCode = appointment.ServiceCode,
                serviceDescription = appointment.ServiceDescription,
                date = appointment.Date.ToString("yyyy-MM-dd"),
                startTime = appointment.StartTime.ToString("HH:mm:ss"),
                endTime = appointment.EndTime.ToString("HH:mm:ss"),
                status = appointment.Status,
                appointmentNo = appointment.AppointmentNo,
                numVehicle = appointment.NumVehicle,
                pontId = appointment.PontId,
            };

            var json = JsonSerializer.Serialize(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync(url, content);
            var responseText = await response.Content.ReadAsStringAsync();
            Console.WriteLine("BC RESPONSE: " + responseText);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"BC error: {responseText}");
        }

        // ── GET AGENCIES ───────────────────────────────────────────────
        public async Task<List<AgencyDto>> GetAgenciesAsync()
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AgencyAPI";

            Console.WriteLine($"[AGENCIES] GET → {url}");

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[AGENCIES] ❌ Erreur BC : {content}");
                    return new List<AgencyDto>();
                }

                var bcResponse = JsonSerializer.Deserialize<BcAgencyResponse>(
                    content,
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );

                var agencies = bcResponse?.value ?? new List<AgencyDto>();
                Console.WriteLine($"[AGENCIES] {agencies.Count} agence(s) trouvée(s)");
                return agencies;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AGENCIES] ❌ Exception : {ex.Message}");
                return new List<AgencyDto>();
            }
        }
    }

}

