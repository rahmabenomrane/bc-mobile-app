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
    modifyAllowed = true;
    insertAllowed = true;
    deleteAllowed = false;
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
      
        ExistingCustomer.Reset();
        ExistingCustomer.SetRange(Phone, Rec.Phone);
        if ExistingCustomer.FindFirst() then
            Error('Ce numéro de téléphone est déjà utilisé.');

        
        NewCustomer.Init();
        NewCustomer.NumCustomer := 'CUST' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 16);

      
        Salt := AuthMgt.GenerateSalt();
        NewCustomer.PasswordSalt := Salt;
        NewCustomer.PasswordHash := AuthMgt.HashPassword(PlainPassword, Salt);

      
        NewCustomer.Name := Rec.Name;
        NewCustomer.Phone := Rec.Phone;
        NewCustomer.Email := Rec.Email;
        NewCustomer.Address := Rec.Address;
        NewCustomer.civility := Rec.civility;

        NewCustomer.Insert(true);

        exit(false);
    end;

}