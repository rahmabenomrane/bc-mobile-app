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

            Console.WriteLine($"[LOGIN] POST → {url}");
            Console.WriteLine($"[LOGIN] Body → {bodyJson}");

            var bodyContent = new StringContent(bodyJson, Encoding.UTF8, "application/json");

            try
            {
                var response = await client.PostAsync(url, bodyContent);
                var content = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"[LOGIN] Status  → {response.StatusCode}");
                Console.WriteLine($"[LOGIN] Content → {content}");

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

                // BC peut retourner le résultat directement ou dans "value"
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

                // Lecture null-safe de chaque champ
                var token = root.TryGetProperty("token", out var t) ? t.GetString() ?? "" : "";
                var customerNumber = root.TryGetProperty("customerNumber", out var cn) ? cn.GetString() ?? "" : "";
                var expiresAt = root.TryGetProperty("expiresAt", out var ea) ? ea.GetString() ?? "" : "";

                Console.WriteLine($"[LOGIN] customerNumber extrait : {customerNumber}");

                if (string.IsNullOrEmpty(customerNumber))
                {
                    // Affiche toutes les clés disponibles pour debug
                    Console.WriteLine("[LOGIN] ⚠️ customerNumber vide — clés disponibles :");
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
                    Civility = root.TryGetProperty("civility", out var civ) ? civ.GetString() ?? "" : ""
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET CUSTOMER] ❌ Exception: {ex.Message}");
                return null;
            }
        }

        // ── UPDATE CUSTOMER PROFILE ───────────────────────────────────────────
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

            Console.WriteLine($"[UPDATE PROFILE] PATCH → {url}");
            Console.WriteLine($"[UPDATE PROFILE] Body → {bodyJson}");

            try
            {
                var response = await client.PatchAsync(url, bodyContent);
                var content = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"[UPDATE PROFILE] Status → {response.StatusCode}");

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
                    return true; // En cas d'erreur, on assume que c'est unique

                var json = JsonDocument.Parse(content);
                if (json.RootElement.TryGetProperty("value", out var valueEl))
                {
                    // Si y'a des résultats, le phone n'est pas unique
                    return valueEl.GetArrayLength() == 0;
                }

                return true;
            }
            catch
            {
                return true;
            }
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

            var bodyJson = JsonSerializer.Serialize(new
            {
                phone = request.Phone,
                email = request.Email,
                firstName = request.FirstName,
                lastName = request.LastName,
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

        // ── GET VEHICLES ───────────────────────────────────────────
        public async Task<List<VehicleDto>> GetCustomerVehiclesAsync(string customerNum)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/StaVehicleAPI?$filter=numCustomer eq '{customerNum}'";

            Console.WriteLine($"[VEHICLES] GET → {url}");

            try
            {
                var response = await client.GetAsync(url);
                var content = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"[VEHICLES] Status  → {response.StatusCode}");

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
                    RegistrationNumber = v.RegistrationNumber
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
        //customer's appointments 
        public async Task<List<AppointmentDto>> GetCustomerAppointmentsAsync(string customerNumber)
        {
            var vehicles =
                await GetCustomerVehiclesAsync(customerNumber);

            var vehicleNumbers =
                vehicles.Select(v => v.NumVehicle).ToList();

            var client = CreateWindowsAuthClient();

            var response =
                await client.GetAsync($"{ODataBase}/AppointmentAPI");

            var json =
                await response.Content.ReadAsStringAsync();

            var data =
                JsonSerializer.Deserialize<CreateAppointmentResponse>(
                    json,
                    new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

            return data?.value?
                .Where(a => vehicleNumbers.Contains(a.NumVehicle))
                .OrderBy(a => a.Date)
                .ToList()
                ?? new List<AppointmentDto>();
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
        public async Task<List<ServiceDto>> GetServicesByAgencyAsync(string agencyCode)
        {
            var client = CreateWindowsAuthClient();

            var agencyServiceUrl = $"{ODataBase}/AgencyServiceAPI";

            var response = await client.GetAsync(agencyServiceUrl);
            var content = await response.Content.ReadAsStringAsync();

            var bcAgencyServices = JsonSerializer.Deserialize<BcAgencyServiceResponse>(
                content,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (bcAgencyServices?.value == null)
                return new List<ServiceDto>();

            Console.WriteLine("=== RAW DATA ===");

            foreach (var a in bcAgencyServices.value)
            {
                Console.WriteLine($"agency='{a.agencyCode}' service='{a.serviceCode}' dispo={a.Disponible}");
            }

            var result = bcAgencyServices.value
                .Where(a =>
                    !string.IsNullOrWhiteSpace(a.agencyCode) &&
                    !string.IsNullOrWhiteSpace(a.serviceCode) &&
                    a.agencyCode.Trim().Equals(agencyCode.Trim(), StringComparison.OrdinalIgnoreCase) &&
                    a.Disponible == true
                )
                .Select(a => new ServiceDto
                {
                    Code = a.serviceCode?.Trim(),
                    Name = a.serviceCode?.Trim(),
                    Description = "",
                    Type = "",
                    Duration = "1h30"
                })
                .ToList();

            return result;
        }

        public async Task<List<AppointmentDto>> GetAppointmentsAsync(string agencyCode, string serviceCode)
        {
            var client = CreateWindowsAuthClient();

            var url =
                $"{ODataBase}/AppointmentAPI?$filter=AgencyCode eq '{agencyCode}' and ServiceCode eq '{serviceCode}'";

            var response = await client.GetAsync(url);

            var json = await response.Content.ReadAsStringAsync();

            Console.WriteLine(json);
            Console.WriteLine("GET URL = " + url);
            var data = JsonSerializer.Deserialize<CreateAppointmentResponse>(
                json,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (data?.value == null)
                return new List<AppointmentDto>();

            return data.value;
        }
        private async Task SaveAppointment(AppointmentDto appointment)
        {
            var client = CreateWindowsAuthClient();
            var url = $"{ODataBase}/AppointmentAPI";

            var body = new
            {
                agencyCode = appointment.AgencyCode,
                serviceCode = appointment.ServiceCode,
                date = appointment.Date.ToString("yyyy-MM-dd"),
                startTime = appointment.StartTime.ToString("HH:mm:ss"),
                endTime = appointment.EndTime.ToString("HH:mm:ss"),
                status = appointment.Status,
                appointmentNo = appointment.AppointmentNo,
                numVehicle = appointment.NumVehicle,
            };

            var json = JsonSerializer.Serialize(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync(url, content);
            var responseText = await response.Content.ReadAsStringAsync();
            Console.WriteLine("BC RESPONSE: " + responseText);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"BC error: {responseText}");
        }
        public async Task<CreateAppointmentResponse> CreateAppointmentAsync(CreateAppointmentDto dto)
        {
            var appointment = new AppointmentDto
            {
                AgencyCode = dto.AgencyCode,
                ServiceCode = dto.ServiceCode,
                Date = dto.Date,

                StartTime = new DateTime(dto.Date.Year, dto.Date.Month, dto.Date.Day, dto.StartTime, 0, 0),
                EndTime = new DateTime(dto.Date.Year, dto.Date.Month, dto.Date.Day, dto.EndTime + 1, 0, 0),

                Status = "Pending",
                AppointmentNo = "RDV-" + DateTime.Now.Ticks.ToString()[..12],

                NumVehicle = dto.VehicleNumber,
                PontId = dto.PontId
            };

            await SaveAppointment(appointment);

            return new CreateAppointmentResponse
            {
                Success = true,
                Message = "Created",
                Data = appointment
            };
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

                Console.WriteLine($"[AGENCIES] Status  → {response.StatusCode}");

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[AGENCIES] ❌ Erreur BC : {content}");
                    return new List<AgencyDto>();
                }

                var bcResponse = JsonSerializer.Deserialize<BcAgencyResponse>(
                    content,
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
                );

                var agencies = bcResponse?.value?.Select(a => new AgencyDto
                {
                    Name = a.Name,
                    Code = a.Code,
                    Address = a.Address,
                    PhoneNo = a.PhoneNo,
                    Email = a.Email,
                    Capacity = a.Capacity,
                    OfficeHours = a.OfficeHours,
                }).ToList() ?? new List<AgencyDto>();

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