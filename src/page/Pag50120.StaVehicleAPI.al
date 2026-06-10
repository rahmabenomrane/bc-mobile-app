page 50120 StaVehicleAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'vehicle';
    EntitySetName = 'vehicles';
    SourceTable = StaVehicle;
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
                }

                field(NumCustomer; Rec."NumCustomer") { }
                field(makeCode; Rec."Make Code") { }
                field(modelCode; Rec."Model Code") { }
                field(motorisation; Rec."Motorisation") { }
                field(Mileage; Rec."Mileage") { }
                field(registrationNumber; Rec."RegistrationNumber") { }

            }
        }
    }
}
