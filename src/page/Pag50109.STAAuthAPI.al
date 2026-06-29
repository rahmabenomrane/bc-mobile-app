page 50109 "STA Auth API"
{
    PageType = API;
    APIPublisher = 'monApp';
    APIGroup = 'auth';
    APIVersion = 'v1.0';
    EntityName = 'session';
    EntitySetName = 'sessions';
    SourceTable = "STA Customer Session";
    DelayedInsert = true;
    ODataKeyFields = Token;

    layout
    {
        area(Content)
        {
            field(token; Rec.Token) { Caption = 'token'; }
            field(phone; Rec.Phone) { Caption = 'phone'; }
            field(password; Rec.Password) { Caption = 'password'; }
            field(expiresAt; Rec.ExpiresAt) { Caption = 'expiresAt'; }
            field(isActive; Rec.IsActive) { Caption = 'isActive'; }
            field(CustomerId; Rec.CustomerId) { Caption = 'customerId'; }
            field(customerNumber; Rec.CustomerNumber) { Caption = 'CustomerNumber'; }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Handler: Codeunit "STA Session API Handler";
        OutToken: Text;
        OutExpiry: DateTime;
        OutCustomerNumber: Code[20];
    begin

        Handler.HandleLogin(Rec.Phone, Rec.Password, OutToken, OutExpiry, OutCustomerNumber);



        // Rec reçoit les données pour la réponse
        Rec.Token := OutToken;
        Rec.ExpiresAt := OutExpiry;
        Rec.IsActive := true;
        Rec.CustomerNumber := OutCustomerNumber;

        // false = BC n'insère pas Rec (déjà fait dans Handler)
        exit(false);
    end;
}