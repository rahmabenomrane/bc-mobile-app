table 50104 "Agency Nonworking Day"
{
    Caption = 'Agency Nonworking Day';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Agency Code"; Code[20])
        {
            Caption = 'Agency Code';
            TableRelation = Agency.Code;
        }
        field(2; Date; Date)
        {
            Caption = 'Date';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Agency Code", Date)
        {
            Clustered = true;
        }
    }
}