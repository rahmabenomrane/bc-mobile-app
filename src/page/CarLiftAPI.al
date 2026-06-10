page 50127 "CarLiftAPI"
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'CarLift';
    EntitySetName = 'CarLifts';
    SourceTable = CarLift;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(agencyCode; Rec."Agency Code")
                {
                    Caption = 'Agency Code';
                }
                field(dailyCapacity; Rec."Daily Capacity")
                {
                    Caption = 'Daily Capacity';
                }
                field(active; Rec.Active)
                {
                    Caption = 'Active';
                }
            }
        }
    }
}