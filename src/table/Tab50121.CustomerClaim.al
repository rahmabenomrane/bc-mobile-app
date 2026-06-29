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
        field(8; registrationNumber; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = StaVehicle.RegistrationNumber;
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
        if Rec."claim No." = 0 then
            Rec."claim No." := GetNextClaimNo();
    end;

    local procedure GetNextClaimNo(): Integer
    var
        CustomerClaim: Record CustomerClaim;
    begin
        CustomerClaim.Reset();
        if CustomerClaim.FindLast() then
            exit(CustomerClaim."claim No." + 1)
        else
            exit(1);
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