table 50107 Service
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ServiceCode"; Code[20]) { }

        field(2; "Description"; Text[100]) { }

        field(3; "Libelle"; Text[100]) { }

        field(4; "Type Service"; Enum ServiceType) { }
    }

    keys
    {
        key(PK; "ServiceCode")
        {
            Clustered = true;
        }
    }
}