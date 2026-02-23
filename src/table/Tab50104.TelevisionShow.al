table 50104 "Television Show"
{
    fields
    {
        field(1; Code; Code[20])
        {
            NotBlank = true;
        }
        field(2; Name; Text[80])
        {
        }
        field(3; Synopsis; Text[250])
        {
        }
        field(4; Status; Option)
        {
            OptionCaption = 'Active,Finished';
            OptionMembers = Active,Finished;
            // Ça définit ce que l’utilisateur voit à l’écran.
        }
        field(5; "First Aired"; Date)
        {
        }
        field(6; "Last Aired"; Date)
        {
        }
        field(7; "Created By"; Code[50])
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        Rec."Created By" := USERID();
    end;
}
