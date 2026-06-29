codeunit 50101 "STA Session API Handler"
{
    trigger OnRun()
    begin
    end;

    procedure HandleLogin(Phone: Text; Password: Text; var OutToken: Text; var OutExpiry: DateTime; var OutCustomerNumber: Code[20])
    var
        AuthMgt: Codeunit "STA Auth Management";
        Session: Record "STA Customer Session";
        OldSession: Record "STA Customer Session";
        Client: Record StaCustomer;
        NewToken: Text;
    begin
        // Chercher client
        Client.Reset();
        Client.SetRange(Phone, Phone);

        if not Client.FindFirst() then
            Error('Utilisateur introuvable.');

        // Supprimer anciennes sessions
        OldSession.Reset();
        OldSession.SetRange(Phone, Phone);

        if OldSession.FindSet() then
            OldSession.DeleteAll(true);

        // Générer token
        NewToken := AuthMgt.LoginClient(Phone, Password);

        // Créer session
        Session.Init();

        Session.Token := NewToken;

        Session.Phone := Phone;

        Session.CustomerId := Client.SystemId;

        Session.CustomerNumber := Client.NumCustomer;

        Session.IsActive := true;

        Session.CreatedAt := CurrentDateTime();

        Session.ExpiresAt := CurrentDateTime() + 86400000;

        Session.Insert(true);
        OutCustomerNumber := Client.NumCustomer;
        OutToken := NewToken;

        OutExpiry := Session.ExpiresAt;
    end;
}