table 50105 StaCustomer
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; NumCustomer; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; FirstName; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(4; LastName; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(3; Address; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(5; Phone; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(6; Email; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(7; Image;  Media)
        {
            DataClassification = ToBeClassified;

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