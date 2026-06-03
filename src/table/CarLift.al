table 50122 "CarLift"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
        }

        field(2; "Description"; Text[100])
        {
        }

        field(3; "Agency Code"; Code[20])
        {
            TableRelation = Agency.Code;
        }

        field(4; "Daily Capacity"; Integer)
        {
        }

        field(5; "Active"; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if "Agency Code" = '' then
            Error('Agency Code must not be empty');
    end;
}