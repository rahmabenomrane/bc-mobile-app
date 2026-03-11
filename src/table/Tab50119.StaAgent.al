table 50119 StaAgent
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Agent No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Login"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Password"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Agent Type"; Enum AgentType)
        {
            DataClassification = ToBeClassified;

        }
        field(5; "Num Agency"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Agency.Code;
        }
        field(6; "hiring date"; Date)
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(Key1; "Agent No.")
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