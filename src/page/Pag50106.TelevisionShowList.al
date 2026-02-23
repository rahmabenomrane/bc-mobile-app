page 50106 "Television Show List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Television Show Card";
    SourceTable = "Television Show";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {

                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("First Aired"; Rec."First Aired")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}
