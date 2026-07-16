page 50102 "Agency Map Part"
{
    PageType = CardPart;
    Caption = 'Carte GPS';
    ApplicationArea = All;
    SourceTable = Agency;

    layout
    {
        area(Content)
        {
            usercontrol(MapControl; AgencyMapPicker)
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    if (Rec.Latitude <> 0) or (Rec.Longitude <> 0) then
                        CurrPage.MapControl.SetCoordinates(Rec.Latitude, Rec.Longitude);
                end;

                trigger CoordinatesSelected(Lat: Decimal; Lng: Decimal; Confirmed: Boolean; Address: Text)
                begin
                    if not Confirmed then exit;

                    Rec.Latitude := Lat;
                    Rec.Longitude := Lng;
                    if Address <> '' then
                        Rec.Address := CopyStr(Address, 1, MaxStrLen(Rec.Address));
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure SetCoordinates(NewLat: Decimal; NewLng: Decimal)
    begin
        CurrPage.MapControl.SetCoordinates(NewLat, NewLng);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCoordinatesReceived(AgencyCode: Code[20]; Lat: Decimal; Lng: Decimal; NewAddress: Text[100])
    begin
    end;
}