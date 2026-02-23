page 50109 "Television Show Card"
{
    PageType = Card;
    SourceTable = "Television Show";
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Synopsis; Rec.Synopsis)
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
