codeunit 50114 "STA Auth API Service"
{
    [ServiceEnabled]
    procedure Login(Phone: Text; Password: Text): Text
    var
        AuthMgt: Codeunit "STA Auth Management";
        Json: JsonObject;
        Token: Text;
        Result: Text;
    begin
        Token := AuthMgt.LoginClient(Phone, Password);

        Json.Add('token', Token);
        Json.Add('expiresAt', Format(CurrentDateTime() + 86400000));
        Json.WriteTo(Result);
        exit(Result);
    end;
}