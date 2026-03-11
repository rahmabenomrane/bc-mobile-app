page 50112 StaVehicleCard
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = StaVehicle;

    layout
    {
        area(Content)
        {
            group("General information")
            {
                field(Name; Rec."NumVehicle")
                {
                    ApplicationArea = All;

                }
                field("Make Code"; Rec."Make Code")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}