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

                field(vehicleNo; Rec."Vehicle No.") { }
                field(vin; Rec.VIN) { }
                field(registrationNo; Rec."Registration No.") { }

                field(makeCode; Rec."Make Code") { }
                field(modelCode; Rec."Model Code") { }

                field(productionYear; Rec."Production Year") { }

                field(statusCode; Rec."Status Code") { }

                field(customerNo; Rec."Customer No.") { }

                field(blocked; Rec.Blocked) { }
                field(reserved; Rec.Reserved) { }

                field(inventory; Rec.Inventory) { }

                field(creationDate; Rec."Creation Date") { }
                field(lastDateModified; Rec."Last Date Modified") { }
            }
        }
    }
}
