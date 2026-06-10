using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using StaBackend.Services;
using StaBackend.Config;

var builder = WebApplication.CreateBuilder(args);

// 1. Lire la configuration JWT
var jwtKey = builder.Configuration["Jwt:Key"];
var jwtIssuer = builder.Configuration["Jwt:Issuer"];
var jwtAudience = builder.Configuration["Jwt:Audience"];

Console.WriteLine($"JWT Config - Key: {!string.IsNullOrEmpty(jwtKey)}, Issuer: {jwtIssuer}, Audience: {jwtAudience}");

// 2. Configuration JWT 
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey ?? "FALLBACK_KEY_DO_NOT_USE_IN_PRODUCTION")),
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero  // ← Important pour éviter les problèmes d'expiration
    };

    // Ajoutez des logs pour debug
    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            Console.WriteLine($"🔴 JWT Authentication Failed: {context.Exception.Message}");
            if (context.Exception is SecurityTokenExpiredException)
                Console.WriteLine("   → Token expiré");
            if (context.Exception is SecurityTokenInvalidSignatureException)
                Console.WriteLine("   → Signature invalide (clé incorrecte)");
            if (context.Exception is SecurityTokenInvalidIssuerException)
                Console.WriteLine($"   → Issuer invalide (attendu: {jwtIssuer})");
            if (context.Exception is SecurityTokenInvalidAudienceException)
                Console.WriteLine($"   → Audience invalide (attendu: {jwtAudience})");
            return Task.CompletedTask;
        },
        OnTokenValidated = context =>
        {
            Console.WriteLine("✅ JWT Token validé avec succès!");
            var claims = context.Principal?.Claims;
            if (claims != null)
            {
                foreach (var claim in claims)
                {
                    if (claim.Type == "CustomerNumber")
                        Console.WriteLine($"   → CustomerNumber: {claim.Value}");
                }
            }
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization();


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 4. Configuration BcSettings
builder.Services.Configure<BcSettings>(builder.Configuration.GetSection("BcSettings"));
builder.Services.AddSingleton<IBcService, BcService>();
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
builder.Services.AddSingleton<ConfirmationTokenStore>();
builder.Services.AddScoped<EmailService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();