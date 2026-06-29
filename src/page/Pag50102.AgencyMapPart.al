page 50102 "Agency Map Part"
{
    PageType = CardPart;
    Caption = 'Agency Map Part';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            usercontrol(MapControl; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                var
                    MapHtml: Codeunit "Agency Map Html";
                begin
                    CurrPage.MapControl.Navigate(MapHtml.GetMapDataUrl());
                end;

                trigger DocumentReady()
                begin
                    if (StoredLat <> 0) or (StoredLng <> 0) then
                        InjectCoords();
                end;

                trigger Callback(data: Text)
                var
                    JsonObj: JsonObject;
                    TypeToken: JsonToken;
                    LatToken: JsonToken;
                    LngToken: JsonToken;
                    ConfToken: JsonToken;
                    NewLat: Decimal;
                    NewLng: Decimal;
                    IsConfirmed: Boolean;
                begin
                    if not JsonObj.ReadFrom(data) then exit;

                    if JsonObj.Get('type', TypeToken) then
                        if TypeToken.AsValue().AsText() <> 'AGENCY_COORDS' then exit;

                    if not JsonObj.Get('lat', LatToken) then exit;
                    if not JsonObj.Get('lng', LngToken) then exit;
                    if not JsonObj.Get('confirmed', ConfToken) then exit;

                    Evaluate(NewLat, LatToken.AsValue().AsText());
                    Evaluate(NewLng, LngToken.AsValue().AsText());
                    Evaluate(IsConfirmed, ConfToken.AsValue().AsText());

                    OnCoordinatesReceived(NewLat, NewLng, IsConfirmed);
                end;
            }
        }
    }

    var
        StoredLat: Decimal;
        StoredLng: Decimal;

    procedure SetCoordinates(NewLat: Decimal; NewLng: Decimal)
    begin
        StoredLat := NewLat;
        StoredLng := NewLng;
        InjectCoords();
    end;

    local procedure InjectCoords()
    var
        Script: Text;
    begin
        // ← PostMessage au lieu de Invoke
        Script := StrSubstNo(
            'if(typeof setCoords==="function")setCoords("%1","%2");',
            Format(StoredLat, 0, 9),
            Format(StoredLng, 0, 9)
        );
        CurrPage.MapControl.PostMessage(Script, '*', false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnCoordinatesReceived(Lat: Decimal; Lng: Decimal; Confirmed: Boolean)
    begin
    end;
}