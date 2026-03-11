table 50107 Service
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20]) { }
        field(2; "Description"; Text[100]) { }
        field(3; "libelle"; Integer) { }
        field(4; "Type Service"; Enum ServiceType ) { }       
        field(5; "PrixBase"; Decimal) { }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
