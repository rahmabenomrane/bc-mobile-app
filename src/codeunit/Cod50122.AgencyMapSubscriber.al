codeunit 50122 "Agency Map Subscriber"
{
    [EventSubscriber(ObjectType::Page, Page::"Agency Map Part", 'OnCoordinatesReceived', '', false, false)]
    local procedure OnMapCoordinatesReceived(AgencyCode: Code[20]; Lat: Decimal; Lng: Decimal; NewAddress: Text[100])
    var
        Agency: Record Agency;
    begin
        if AgencyCode = '' then exit;
        if not Agency.Get(AgencyCode) then exit;

        // Les données sont déjà persistées côté Part (Rec.Modify(true) y a été fait),
        // donc ici on relit juste pour être sûr, ou on peut s'en servir pour d'autres actions.
        OnAfterAgencyUpdated(Agency);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAgencyUpdated(var Agency: Record Agency)
    begin
    end;
}