page 50115 StaCustomerAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = StaCustomer;
    ODataKeyFields = SystemId;
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

                field(firstName; Rec.FirstName)
                {
                    Caption = 'First Name';
                }

                field(lastName; Rec.LastName)
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
}