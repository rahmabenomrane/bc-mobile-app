table 50107 ServiceAgence
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ServiceCode"; Code[20]) { }
        field(2; "Description"; Text[100]) { }
        field(3; "libelle"; Text[100]) { }
        field(4; "Type Service"; Enum ServiceType) { }
        field(5; "PrixBase"; Decimal) { }
    }

    keys
    {
        key(PK; "ServiceCode") { Clustered = true; }
    }
}
