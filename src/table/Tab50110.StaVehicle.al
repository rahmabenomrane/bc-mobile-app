table 50110 StaVehicle
{
    Caption = 'Vehicle';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "NumVehicle"; Code[20])
        {
            Caption = 'Vehicle Number';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                tcDMS001: label 'You can not delete value of %1 field .';
            begin
                if (Rec."NumVehicle" = '') and (xRec."NumVehicle" <> '') then
                    Error(tcDMS001, FieldCaption("NumVehicle"));

                if (Rec."NumVehicle" = '') and (xRec."NumVehicle" = '') then
                    exit;
            end;
        }

        field(2; "Make Code"; Code[20])
        {
            Caption = 'Make Code';
            TableRelation = Make;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Make Code" <> xRec."Make Code" then
                    Validate("Model Code", '');
            end;
        }

        field(3; "Model Code"; Code[20])
        {
            Caption = 'Model Code';
            TableRelation = Model.Code where("Make Code" = field("Make Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Model Code" <> xRec."Model Code" then
                    Validate("Motorisation", '');
            end;
        }

        field(4; "Motorisation"; Code[20])
        {
            Caption = 'Motorisation';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                if xRec."Motorisation" <> '' then
                    if "Motorisation" <> xRec."Motorisation" then
                        TestNoOpenEntriesExist(FieldCaption("Motorisation"));
            end;
        }
        field(5; NumCustomer; Code[20])
        {
            Caption = 'Customer Number';
            TableRelation = StaCustomer."NumCustomer";
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(Key1; "NumVehicle")
        {
            Clustered = true;
        }
        key(Key2; "Make Code", "Model Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "NumVehicle", "Make Code", "Model Code", "Motorisation", "NumCustomer")
        {
        }
    }

    trigger OnInsert()
    begin
        if "NumVehicle" = '' then begin
            AssignSerialNo();
        end;


    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    var
        InventorySetup: Record "Inventory Setup";
        HideMsg: boolean;
        Text019: label 'You cannot change %1 because there are one or more open ledger entries for this item.';

    procedure AssignSerialNo()
    var
        cuNoSeries: Codeunit "No. Series";
        codNewSerialNo: Code[20];
        codSerialNos: Code[20];
        tcDMS001: label '%1 is set already.';
    begin
        if "NumVehicle" <> '' then
            Error(tcDMS001, FieldCaption("NumVehicle"));

        InventorySetup.Get();
        InventorySetup.TestField("Vehicle Serial No. Nos.");
        codSerialNos := InventorySetup."Vehicle Serial No. Nos.";
        codNewSerialNo := cuNoSeries.GetNextNo(codSerialNos, WorkDate());

        Validate("NumVehicle", codNewSerialNo);
    end;

    procedure TestNoOpenEntriesExist(CurrentFieldName: Text[100])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin

        ItemLedgEntry.SetRange("Serial No.", "NumVehicle");
        ItemLedgEntry.SetRange(Open, true);
        if not ItemLedgEntry.IsEmpty then
            Error(Text019, CurrentFieldName);
    end;

    Procedure fHideMsg(pHideMsg: Boolean)
    begin
        HideMsg := pHideMsg;
    end;

    Procedure fgetHideMsg(): Boolean
    begin
        EXIT(HideMsg);
    end;
}