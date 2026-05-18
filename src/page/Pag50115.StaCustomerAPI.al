page 50115 StaCustomerAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = StaCustomer;
    ODataKeyFields = NumCustomer;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(numCustomer; Rec.NumCustomer)
                {
                    Caption = 'Customer Number';
                }

                field(lastName; Rec.Name)
                {
                    Caption = 'Last Name';
                }
                field(password; PlainPassword)
                {
                    Caption = 'Password';
                }

                field(address; Rec.Address)
                {
                    Caption = 'Address';
                }

                field(phone; Rec.Phone)
                {
                    Caption = 'Phone';
                }

                field(email; Rec.Email)
                {
                    Caption = 'Email';
                }

                field(image; Rec.Image)
                {
                    Caption = 'Image';
                }
                field(civility; Rec.civility)
                {
                    Caption = 'Civility';
                }
            }

        }
    }
    var
        PlainPassword: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        AuthMgt: Codeunit "STA Auth Management";
        Salt: Text;
        NewCustomer: Record StaCustomer;
        ExistingCustomer: Record StaCustomer;
    begin
        // 1. Vérifier si phone déjà utilisé
        ExistingCustomer.Reset();
        ExistingCustomer.SetRange(Phone, Rec.Phone);
        if ExistingCustomer.FindFirst() then
            Error('Ce numéro de téléphone est déjà utilisé.');

        // 2. Générer NumCustomer unique
        NewCustomer.Init();
        NewCustomer.NumCustomer := 'CUST' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 16);

        // 3. Hash password
        Salt := AuthMgt.GenerateSalt();
        NewCustomer.PasswordSalt := Salt;
        NewCustomer.PasswordHash := AuthMgt.HashPassword(PlainPassword, Salt);

        // 4. Copier les champs
        NewCustomer.Name := Rec.Name;
        NewCustomer.Phone := Rec.Phone;
        NewCustomer.Email := Rec.Email;
        NewCustomer.Address := Rec.Address;
        NewCustomer.civility := Rec.civility;

        // 5. Insérer manuellement
        NewCustomer.Insert(true);

        // ✅ false = BC n'insère pas Rec une 2ème fois
        exit(false);
    end;
}