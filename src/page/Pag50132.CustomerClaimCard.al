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
                    Caption = 'Numéro de réclamation';
                }

                field(Status; Rec.Status)
                {
                    Caption = 'Statut';
                }

                field(Priority; Rec.Priority)
                {
                    Editable = false;
                    Caption = 'Priorité';
                }

                field(CreationDate; Rec.creationDate)
                {
                    Editable = false;
                    Caption = 'Date de création';
                }
            }

            group(Description)
            {
                Caption = 'Description de la réclamation';

                field(ClaimDescription; Rec.description)
                {
                    Caption = 'Description';
                    MultiLine = true;
                    ShowCaption = true;
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

                field(email; Rec.customeremail)
                {
                    Caption = 'Adresse e-mail';
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

            part(ClaimMessages; "Claim Message ListPart")
            {
                Caption = 'Communication avec le client';
                ApplicationArea = All;

                SubPageLink =
                "Claim No." = field("claim No.");
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
            if Model.Get(
                Vehicle."Make Code",
                Vehicle."Model Code"
            ) then begin
                VehicleModel := Model."Commercial Name";
            end;
        end;

        CurrPage.ClaimMessages.Page.SetClaimNo(Rec."claim No.");
    end;
}