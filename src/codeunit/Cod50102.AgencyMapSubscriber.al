codeunit 50122 "Agency Map Subscriber"
{
    [EventSubscriber(ObjectType::Page, Page::"Agency Map Part", 'OnCoordinatesReceived', '', false, false)]
    local procedure OnMapCoordinatesReceived(Lat: Decimal; Lng: Decimal; Confirmed: Boolean)
    var
        Agency: Record Agency;
    begin
       
        if not Confirmed then exit;  

        if CurrentAgencyCode = '' then exit;

        if not Agency.Get(CurrentAgencyCode) then exit;

        Agency.Latitude := Lat;
        Agency.Longitude := Lng;
        Agency.Modify(true);
    end;

    var
        CurrentAgencyCode: Code[20];

    procedure SetCurrentAgency(AgencyCode: Code[20])
    begin
        CurrentAgencyCode := AgencyCode;
    end;
}