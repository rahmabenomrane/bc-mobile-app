table 50106 RendezVous
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(3; "Agence Code"; Code[20]) { TableRelation = Agence.Code; }
        field(4; "Service Code"; Code[20]) { TableRelation = Service.Code; }
        field(5; "Date"; Date) { }
        field(6; "Heure"; Time) { }
        field(7; "Status"; Option)
        {
            OptionMembers = Planifié,Annulé,Terminé;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}
