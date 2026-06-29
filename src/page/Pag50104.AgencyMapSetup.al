page 50104 "Agency Map Setup"
{
    PageType = Card;
    SourceTable = "Agency Map Setup";
    Caption = 'Configuration Carte GPS';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Google Maps';

                field(GoogleMapsApiKey; Rec.GoogleMapsApiKey)
                {
                    ApplicationArea = All;
                    Caption = 'Clé API Google Maps';
                    ToolTip = 'Obtenez votre clé sur console.cloud.google.com';
                    ExtendedDatatype = Masked;  // Masque la clé à l'écran
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.PrimaryKey := '';
            Rec.Insert();
        end;
    end;
}