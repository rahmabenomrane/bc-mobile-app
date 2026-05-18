codeunit 50100 "STA Auth Management"
{
    procedure LoginClient(Phone: Text; Password: Text): Text
    var
        Client: Record StaCustomer;
        Session: Record "STA Customer Session";
        Hashed: Text;
        Token: Text;
    begin
        Client.Reset();
        Client.SetRange(Phone, Phone);

        if not Client.FindFirst() then
            Error('Utilisateur introuvable.');

        Hashed := HashPassword(Password, Client.PasswordSalt);
        if Client.PasswordHash <> Hashed then
            Error('Mot de passe incorrect.');

        // Désactiver anciennes sessions
        Session.SetRange(CustomerId, Client.SystemId);
        Session.SetRange(IsActive, true);
        if Session.FindSet() then
            repeat
                Session.IsActive := false;
                Session.Modify();
            until Session.Next() = 0;

        // ✅ Générer token uniquement — PAS d'Insert ici !
        Token := GenerateToken();
        exit(Token);
    end;

    procedure ValidateToken(Token: Text): Guid
    var
        Session: Record "STA Customer Session";
    begin
        if Token = '' then
            Error('Token requis.');

        Session.SetRange(Token, Token);
        Session.SetRange(IsActive, true);

        if not Session.FindFirst() then
            Error('Token invalide.');

        if Session.ExpiresAt < CurrentDateTime() then begin
            Session.IsActive := false;
            Session.Modify();
            Error('Session expirée, veuillez vous reconnecter.');
        end;

        exit(Session.CustomerId);
    end;

    procedure LogoutClient(Token: Text)
    var
        Session: Record "STA Customer Session";
    begin
        if Token = '' then exit;

        Session.SetRange(Token, Token);
        Session.SetRange(IsActive, true);
        if Session.FindFirst() then begin
            Session.IsActive := false;
            Session.Modify();
        end;
    end;

    procedure HashPassword(PlainPassword: Text; Salt: Text): Text
    var
        Crypto: Codeunit "Cryptography Management";
    begin
        exit(Crypto.GenerateHash(Salt + PlainPassword, 2)); // SHA-256
    end;

    procedure GenerateSalt(): Text
    var
        GUID: Guid;
    begin
        GUID := CreateGuid();
        exit(Format(GUID));
    end;

    local procedure GenerateToken(): Text
    var
        GUID1: Guid;
        GUID2: Guid;
    begin
        GUID1 := CreateGuid();
        GUID2 := CreateGuid();
        exit(DelChr(Format(GUID1) + Format(GUID2), '=', '{}-'));
    end;
}