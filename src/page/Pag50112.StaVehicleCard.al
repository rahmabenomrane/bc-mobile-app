page 50112 StaVehicleCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = StaVehicle;
    Caption = 'Vehicle Card';

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General Information';

                field("Vehicle No."; Rec."NumVehicle")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Unique vehicle number.';

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
                Caption = 'Vehicle Details';

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
                field("Registration number"; Rec."Registration number")
                {
                    ApplicationArea = All;
                }
                field("Kilométrage"; Rec."Mileage")
                {
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
                Caption = 'Delete Vehicle';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Delete(true);
                end;
            }
        }
    }
   
}