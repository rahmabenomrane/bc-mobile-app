table 50121 CustomerClaim
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "claim No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; creationDate; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(3; customerNo; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = StaCustomer.NumCustomer;
        }
        field(4; description; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(5; status; Enum "Claim Status")
        {
            DataClassification = ToBeClassified;

        }
        field(6; priority; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Low,Medium,High;
            OptionCaption = 'Low,Medium,High';
        }
        field(7; vehicleNo; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = StaVehicle.NumVehicle;
        }
    }

    keys
    {
        key(Key1; "claim No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {

    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}