table 50105 StaCustomer
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; NumCustomer; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(2; FirstName; Text[50])
        {
            DataClassification = CustomerContent;

        }
        field(3; LastName; Text[50])
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
    }

    keys
    {
        key(Key1; NumCustomer)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; NumCustomer, FirstName, LastName, Phone)
        {
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        if NumCustomer = '' then
            NumCustomer := 'CUST' + Format(CreateGuid());
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