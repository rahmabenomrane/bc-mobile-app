page 50111 StaVehicleList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = StaVehicle;

    CardPageId = StaVehicleCard;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Rec."Vehicle No.")
                {
                    ApplicationArea = All;

                }
                field(VIN; Rec.VIN)
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