table 50105 StaCustomer
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; NumCustomer; Code[20])
        {
            DataClassification = CustomerContent;

        }
       
        field(3; Name; Text[50])
        {
            DataClassification = CustomerContent;

        }

        field(9; Address; Text[50])
        {
            DataClassification = CustomerContent;

        }
        field(5; Phone; Text[50])
        {
            DataClassification = CustomerContent;

        }
        field(50000; PasswordHash; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6; Email; Text[50])
        {
            DataClassification = CustomerContent;

        }
        field(7; Image; Media)
        {
            DataClassification = CustomerContent;

        }
        field(8; civility; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Monsieur,Madame';
            OptionMembers = Monsieur,Madame;
        }
        field(10; PasswordSalt; Text[50])
        {
            Caption = 'Password Salt';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; NumCustomer)
        {
            Clustered = true;
        }
        key(Key2; Email)
        {
            Unique = true;
        }
        key(Key3; Phone)
        {
            Unique = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; NumCustomer, Name, Phone)
        {
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        // ✅ Générer seulement si vide
        if NumCustomer = '' then
            NumCustomer := 'CUST' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 16);

        // ✅ Générer salt si vide
        if PasswordSalt = '' then begin
            PasswordSalt := Format(CreateGuid());
        end;
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