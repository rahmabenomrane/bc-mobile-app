page 50104 TableRelationsList
{
    ApplicationArea = All;
    Caption = 'Table Relations List';
    PageType = List;
    SourceTable = "Table Relations Metadata";
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID") { }
                field("Table Name"; Rec."Table Name") { }
                field("Field No."; Rec."Field No.") { }
                field("Field Name"; Rec."Field Name") { }
                field("Related Table ID"; Rec."Related Table ID") { }
                field("Related Table Name"; Rec."Related Table Name") { }
                field("Related Field Name"; Rec."Related Field Name") { }
                field("Condition Value"; Rec."Condition Value") { }
            }
        }
    }
}