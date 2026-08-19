page 50112 StaVehicleCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = StaVehicle;
    Caption = 'Carte de véhicule';

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'Informations générales';

                field("Vehicle No."; Rec."NumVehicle")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Unique vehicle number.';
                    Editable = false;

                }

                field("Customer"; Rec."NumCustomer")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Owner of the vehicle.';
                }
            }

            group("Vehicle Details")
            {
                Caption = 'Détails du véhicule';

                field("Make Code"; Rec."Make Code")
                {
                    ApplicationArea = All;
                }

                field("Model Code"; Rec."Model Code")
                {
                    ApplicationArea = All;
                }

                field("Motorisation"; Rec."Motorisation")
                {
                    ApplicationArea = All;
                }
                field("Registration Number"; Rec."RegistrationNumber")
                {
                    Caption = 'Numéro d''immatriculation';
                    ApplicationArea = All;
                }
                field("Kilométrage"; Rec."Mileage")
                {
                    Caption = 'Kilométrage';
                    ApplicationArea = All;
                }
            }
        }

        area(FactBoxes)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }

            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteVehicle)
            {
                Caption = 'Supprimer Véhicule';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Delete(true);
                end;
            }
        }
    }

}