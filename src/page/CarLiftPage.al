page 50126 "CarLift SubPage"
{
    PageType = ListPart;
    SourceTable = CarLift;
    ApplicationArea = All;

    Editable = true;
    DelayedInsert = true;
    PopulateAllFields = true;

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

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Daily Capacity"; Rec."Daily Capacity")
                {
                    ApplicationArea = All;
                }

                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // trigger OnNewRecord(BelowxRec: Boolean)
    // begin
    //     Rec."Agency Code" := Rec.GetRangeMin("Agency Code");
    // end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Agency Code" := Rec.GetRangeMin("Agency Code");
        exit(true);
    end;
}