table 50103 "Agency Map Setup"
{
    Caption = 'Agency Map Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; GoogleMapsApiKey; Text[250])
        {
            Caption = 'Clé API Google Maps';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PrimaryKey) { Clustered = true; }
    }

    // Accès rapide depuis n'importe où
    procedure GetApiKey(): Text
    var
        Setup: Record "Agency Map Setup";
    begin
        if not Setup.Get('') then
            Error('Clé API Google Maps non configurée. Allez dans Agency Map Setup.');
        if Setup.GoogleMapsApiKey = '' then
            Error('Clé API Google Maps vide. Allez dans Agency Map Setup.');
        exit(Setup.GoogleMapsApiKey);
    end;
}