page 50132 "Customer Claim Card"
{
    PageType = Card;
    SourceTable = CustomerClaim;
    Caption = 'Réclamation du client';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {

            group(General)
            {
                Caption = 'Informations générales';

                field("Claim No."; Rec."claim No.")
                {
                    Editable = false;
                }

                field(Status; Rec.Status)
                {
                }

                field(Priority; Rec.Priority)
                {
                    Editable = false;
                }

                field(CreationDate; Rec.creationDate)
                {
                    Editable = false;
                }
            }


            group(Customer)
            {
                Caption = 'Informations client';


                field(CustomerNo; Rec.customerNo)
                {
                    Caption = 'Numéro du client';
                    Editable = false;
                }


                field(CustomerName; CustomerName)
                {
                    Caption = 'Nom du client';
                    Editable = false;
                }


                field(CustomerPhone; CustomerPhone)
                {
                    Caption = 'Numéro de téléphone';
                    Editable = false;
                }
            }



            group(Vehicle)
            {
                Caption = 'Informations véhicule';


                field(VehicleNo; Rec.vehicleNo)
                {
                    Caption = 'Numéro du véhicule';
                    Editable = false;
                }


                field(Immatriculation; Rec.registrationNumber)
                {
                    Caption = 'Immatriculation';
                    Editable = false;
                }


                field(VehicleModel; VehicleModel)
                {
                    Caption = 'Modèle';
                    Editable = false;
                }
            }



            group(Description)
            {
                Caption = 'Description du réclamation';

                field(ClaimDescription; Rec.description)
                {
                    Caption = 'Description';
                    MultiLine = true;
                    ShowCaption = true;
                    Editable = false;
                }
            }
        }
    }



    var
        CustomerName: Text[100];
        CustomerPhone: Text[30];
        VehicleModel: Text[100];


    trigger OnAfterGetRecord()
    var
        Customer: Record StaCustomer;
        Vehicle: Record StaVehicle;
        Model: Record Model;
    begin

        Clear(CustomerName);
        Clear(CustomerPhone);
        Clear(VehicleModel);


        // Récupération client
        if Customer.Get(Rec.customerNo) then begin

            CustomerName := Customer.Name;
            CustomerPhone := Customer.Phone;

        end;



        // Récupération véhicule
        if Vehicle.Get(Rec.vehicleNo) then begin

            if Model.Get(Vehicle."Make Code",
                         Vehicle."Model Code") then begin

                VehicleModel := Model."Commercial Name";

            end;

        end;

    end;
}