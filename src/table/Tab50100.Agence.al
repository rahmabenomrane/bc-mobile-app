table 50100 Agence
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20]) { }
        field(2; "Nom"; Text[100]) { }
        field(3; "Adresse"; Text[150]) { }
        field(4; "Telephone"; Text[20]) { }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
