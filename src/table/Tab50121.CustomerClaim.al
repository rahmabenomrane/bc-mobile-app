table 50121 CustomerClaim
{
    Caption = 'Customer Claim';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "claim No."; Code[20])
        {
            Caption = 'Claim No.';
            DataClassification = ToBeClassified;
        }

        field(2; creationDate; Date)
        {
            Caption = 'Creation Date';
            DataClassification = ToBeClassified;
        }

        field(3; customerNo; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = StaCustomer.NumCustomer;
        }
        field(9; customeremail; Text[100])
        {
            Caption = 'Customer Email';
            DataClassification = CustomerContent;
        }

        field(4; description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(5; status; Enum "Claim Status")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
        }

        field(6; priority; Option)
        {
            Caption = 'Priority';
            DataClassification = ToBeClassified;
            OptionMembers = Low,Medium,High;
            OptionCaption = 'Low,Medium,High';
        }

        field(7; vehicleNo; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = ToBeClassified;
            TableRelation = StaVehicle.NumVehicle;
        }

        field(8; registrationNumber; Code[20])
        {
            Caption = 'Registration Number';
            DataClassification = ToBeClassified;
            TableRelation = StaVehicle.RegistrationNumber;
        }

        field(20; CustomerName; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(
                StaCustomer.Name
                where(NumCustomer = field(customerNo))
            );
            Editable = false;
        }

        field(21; CustomerPhone; Code[20])
        {
            Caption = 'Phone';
            FieldClass = FlowField;
            CalcFormula = lookup(
                StaCustomer.Phone
                where(NumCustomer = field(customerNo))
            );
            Editable = false;
        }

        field(22; VehicleModelCode; Code[20])
        {
            Caption = 'Model';
            FieldClass = FlowField;
            CalcFormula = lookup(
                StaVehicle."Model Code"
                where(NumVehicle = field(vehicleNo))
            );
            Editable = false;
        }
    }

    keys
    {
        key(PK; "claim No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "claim No." = '' then
            "claim No." := GetNextClaimNo();

        if creationDate = 0D then
            creationDate := Today;
    end;

    local procedure GetNextClaimNo(): Code[20]
    var
        CustomerClaim: Record CustomerClaim;
        LastNo: Integer;
        NumberText: Text;
    begin
        CustomerClaim.Reset();
        CustomerClaim.SetCurrentKey("claim No.");

        if CustomerClaim.FindLast() then begin
            NumberText := CopyStr(CustomerClaim."claim No.", 3);

            if not Evaluate(LastNo, NumberText) then
                LastNo := 0;

            LastNo += 1;
        end else
            LastNo := 1;

        exit(
            'CL' +
            Format(
                LastNo,
                4,
                '<Integer,4><Filler Character,0>'
            )
        );
    end;
}