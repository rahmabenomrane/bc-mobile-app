using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using StaBackend.Services;
using StaBackend.Config;
using QuestPDF.Infrastructure;

var builder = WebApplication.CreateBuilder(args);


var jwtKey = builder.Configuration["Jwt:Key"];
var jwtIssuer = builder.Configuration["Jwt:Issuer"];
var jwtAudience = builder.Configuration["Jwt:Audience"];

Console.WriteLine(
    $"JWT Config - Key: {!string.IsNullOrEmpty(jwtKey)}, " +
    $"Issuer: {jwtIssuer}, Audience: {jwtAudience}"
);

builder.Services.AddCors(options =>
{
    options.AddPolicy(
        "AllowAll",
        policy =>
        {
            policy
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        }
    );

    options.AddPolicy(
        "Development",
        policy =>
        {
            policy
                .WithOrigins(
                    "http://localhost:5000",
                    "http://127.0.0.1:5000",
                    "http://localhost:3000",
                    "http://127.0.0.1:3000",
                    "http://localhost:8080",
                    "http://127.0.0.1:8080"
                )
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        }
    );

    options.AddPolicy(
        "Production",
        policy =>
        {
            policy
                .WithOrigins(
                    "https://votre-domaine.com",
                    "https://www.votre-domaine.com"
                )
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        }
    );
});

builder.Services
    .AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme =
            JwtBearerDefaults.AuthenticationScheme;

        options.DefaultChallengeScheme =
            JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.SaveToken = true;

        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,

                IssuerSigningKey =
                    new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(
                            jwtKey ??
                            "FALLBACK_KEY_DO_NOT_USE_IN_PRODUCTION"
                        )
                    ),

                ValidateIssuer = true,
                ValidIssuer = jwtIssuer,

                ValidateAudience = true,
                ValidAudience = jwtAudience,

                ValidateLifetime = true,

                ClockSkew = TimeSpan.Zero
            };

        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.WriteLine(
                    $"🔴 JWT Authentication Failed: " +
                    $"{context.Exception.Message}"
                );

                if (context.Exception
                    is SecurityTokenExpiredException)
                {
                    Console.WriteLine(
                        "   → Token expiré"
                    );
                }

                if (context.Exception
                    is SecurityTokenInvalidSignatureException)
                {
                    Console.WriteLine(
                        "   → Signature invalide " +
                        "(clé incorrecte)"
                    );
                }

                if (context.Exception
                    is SecurityTokenInvalidIssuerException)
                {
                    Console.WriteLine(
                        $"   → Issuer invalide " +
                        $"(attendu: {jwtIssuer})"
                    );
                }

                if (context.Exception
                    is SecurityTokenInvalidAudienceException)
                {
                    Console.WriteLine(
                        $"   → Audience invalide " +
                        $"(attendu: {jwtAudience})"
                    );
                }

                return Task.CompletedTask;
            },

            OnTokenValidated = context =>
            {
                Console.WriteLine(
                    "✅ JWT Token validé avec succès!"
                );

                var claims =
                    context.Principal?.Claims;

                if (claims != null)
                {
                    foreach (var claim in claims)
                    {
                        if (claim.Type ==
                            "CustomerNumber")
                        {
                            Console.WriteLine(
                                $"   → CustomerNumber: " +
                                $"{claim.Value}"
                            );
                        }
                    }
                }

                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();


builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions
            .PropertyNamingPolicy =
            System.Text.Json.JsonNamingPolicy
                .CamelCase;

        options.JsonSerializerOptions
            .DictionaryKeyPolicy =
            System.Text.Json.JsonNamingPolicy
                .CamelCase;
    });


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


builder.Services.Configure<BcSettings>(
    builder.Configuration.GetSection(
        "BcSettings"
    )
);

builder.Services.AddSingleton<
    IBcService,
    BcService
>();


builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection(
        "EmailSettings"
    )
);

builder.Services.AddSingleton<
    ConfirmationTokenStore
>();

builder.Services.AddScoped<
    EmailService
>();

builder.Services.AddHostedService<
    ReminderJob
>();


builder.Services.AddHttpClient();


builder.Services.AddHttpClient<
    IAiDiagnosticService,
    OllamaDiagnosticService
>(
    client =>
    {
        client.BaseAddress =
            new Uri(
                "http://localhost:11434"
            );

        client.Timeout =
            TimeSpan.FromMinutes(9);
    }
);


builder.Services.AddDataProtection();

builder.Services.AddScoped<
    IAppointmentShareService,
    AppointmentShareService
>();


builder.Services.AddScoped<
    IAppointmentPdfService,
    AppointmentPdfService
>();

QuestPDF.Settings.License =
    LicenseType.Community;


var openAiKey =
    builder.Configuration["OpenAI:ApiKey"];

Console.WriteLine(
    $"OpenAI API Key chargée : " +
    $"{!string.IsNullOrEmpty(openAiKey)}"
);

var app = builder.Build();


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();

    app.UseCors(
        "AllowAll"
    );
}
else
{
    app.UseCors(
        "Production"
    );
}


app.UseAuthentication();
app.UseAuthorization();



app.MapControllers();

app.Run();