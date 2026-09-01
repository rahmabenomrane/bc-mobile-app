page 50119 AgencyNonworkingDayAPI
{
    PageType = API;
    APIPublisher = 'STA';
    APIGroup = 'Mobile';
    APIVersion = 'v1.0';
    EntityName = 'AgencyNonworkingDay';
    EntitySetName = 'AgencyNonworkingDays';
    SourceTable = "Agency Nonworking Day";
    DelayedInsert = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("AgencyCode"; Rec."Agency Code")
                {
                    Caption = 'Agency Code';
                }
                field("Date"; Rec.Date)
                {
                    Caption = 'Date';
                }
                field("Description"; Rec.Description)
                {
                    Caption = 'Description';
                }
            }
        }
    }
}