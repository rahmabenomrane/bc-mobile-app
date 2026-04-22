table 50108 ServiceAgence
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Agency Code"; Code[20])
        {
            TableRelation = Agency.Code;
        }

        field(2; "Service Code"; Code[20])
        {
            TableRelation = Service."ServiceCode";
        }

        field(3; "Prix"; Decimal) { }
        field(4; "Duree"; Integer) { } 
        field(5; "Disponible"; Boolean) { }
    }

    keys
    {
        key(PK; "Agency Code", "Service Code")
        {
            Clustered = true;
        }
    }
}