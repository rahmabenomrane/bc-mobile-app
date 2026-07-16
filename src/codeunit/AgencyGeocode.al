codeunit 50123 "Agency Geocode"
{
    procedure GeocodeAddress(Address: Text; var Lat: Decimal; var Lng: Decimal): Boolean
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        Headers: HttpHeaders;
        Uri: Codeunit Uri;
        ResponseText: Text;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        ResultToken: JsonToken;
        LatToken: JsonToken;
        LonToken: JsonToken;
        Url: Text;
    begin
        if Address = '' then exit(false);

        Url := 'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + Uri.EscapeDataString(Address);

        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method := 'GET';
        RequestMsg.GetHeaders(Headers);
        Headers.Add('User-Agent', 'DynamicsBC-AgencyModule/1.0');

        if not Client.Send(RequestMsg, ResponseMsg) then exit(false);
        if not ResponseMsg.IsSuccessStatusCode() then exit(false);

        ResponseMsg.Content().ReadAs(ResponseText);
        if not JsonArr.ReadFrom(ResponseText) then exit(false);
        if JsonArr.Count = 0 then exit(false);

        JsonArr.Get(0, ResultToken);
        JsonObj := ResultToken.AsObject();

        if not JsonObj.Get('lat', LatToken) then exit(false);
        if not JsonObj.Get('lon', LonToken) then exit(false);

        Evaluate(Lat, LatToken.AsValue().AsText());
        Evaluate(Lng, LonToken.AsValue().AsText());
        exit(true);
    end;
}