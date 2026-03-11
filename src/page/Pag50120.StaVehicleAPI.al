page 50120 StaVehicleAPI
{
    PageType = API;
    APIPublisher = 'sta';
    APIGroup = 'mobile';
    APIVersion = 'v1.0';
    EntityName = 'vehicle';
    EntitySetName = 'vehicles';
    SourceTable = StaVehicle;
    DelayedInsert = true; //créer un enregistrement même si tous les champs obligatoires ne sont pas remplis immédiatemen

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

                field(vehicleNo; Rec."NumCustomer") { }
                field(makeCode; Rec."Make Code") { }
                field(modelCode; Rec."Model Code") { }
                field(motorisation; Rec."Motorisation") {}
                    
            }
        }
    }
}
