codeunit 50111 "Agency Map Html"
{
    procedure GetMapDataUrl(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        HtmlContent: Text;
    begin
        HtmlContent := BuildHtml();
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(HtmlContent);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        exit('data:text/html;base64,' + Base64Convert.ToBase64(InStr));
    end;

    local procedure BuildHtml(): Text
    var
        Sb: TextBuilder;
        Setup: Record "Agency Map Setup";
        ApiKey: Text;
    begin
        // Récupère la clé API
        if Setup.Get('') then
            ApiKey := Setup.GoogleMapsApiKey
        else
            ApiKey := '';

        Sb.Append('<!DOCTYPE html><html lang="fr"><head>');
        Sb.Append('<meta charset="utf-8"/>');
        Sb.Append('<meta name="viewport" content="width=device-width,initial-scale=1"/>');
        Sb.Append('<style>');
        Sb.Append('*{margin:0;padding:0;box-sizing:border-box}');
        Sb.Append('body{font-family:Segoe UI,Arial,sans-serif}');
        Sb.Append('#map{width:100%;height:calc(100vh - 54px)}');
        Sb.Append('#bar{height:54px;display:flex;align-items:center;gap:10px;');
        Sb.Append('padding:0 14px;background:#fff;border-bottom:1px solid #ddd;');
        Sb.Append('box-shadow:0 1px 3px rgba(0,0,0,.1)}');
        Sb.Append('#badge{font-size:12px;padding:4px 10px;border-radius:12px;');
        Sb.Append('background:#fff3cd;color:#664d03;border:1px solid #ffc107;white-space:nowrap}');
        Sb.Append('#badge.ok{background:#d1e7dd;color:#0a3622;border-color:#198754}');
        Sb.Append('#coords{flex:1;font-size:12px;color:#555;background:#f8f8f8;');
        Sb.Append('border:1px solid #ddd;border-radius:6px;padding:5px 10px}');
        Sb.Append('#btn{padding:7px 16px;background:#0078d4;color:#fff;border:none;');
        Sb.Append('border-radius:6px;font-size:12px;font-weight:600;cursor:pointer}');
        Sb.Append('#btn:hover{background:#005fa3}');
        Sb.Append('#btn:disabled{background:#bbb;cursor:not-allowed}');
        Sb.Append('</style></head><body>');
        Sb.Append('<div id="bar">');
        Sb.Append('<span id="badge">📍 Cliquez sur la carte pour positionner l''agence</span>');
        Sb.Append('<div id="coords">Aucune coordonnée sélectionnée</div>');
        Sb.Append('<button id="btn" disabled onclick="confirmPos()">✅ Confirmer</button>');
        Sb.Append('</div>');
        Sb.Append('<div id="map"></div>');
        Sb.Append('<script>');
        Sb.Append('var map,marker,selLat=null,selLng=null;');
        Sb.Append('function initMap(){');
        Sb.Append('map=new google.maps.Map(document.getElementById("map"),{');
        Sb.Append('center:{lat:36.8065,lng:10.1815},zoom:12,');
        Sb.Append('streetViewControl:false,fullscreenControl:false,');
        Sb.Append('styles:[{featureType:"poi",elementType:"labels",stylers:[{visibility:"off"}]}]');
        Sb.Append('});');
        Sb.Append('map.addListener("click",function(e){');
        Sb.Append('selLat=e.latLng.lat();selLng=e.latLng.lng();');
        Sb.Append('moveMarker(selLat,selLng);updateBar();sendToBC(false);');
        Sb.Append('});}');
        Sb.Append('function moveMarker(la,ln){');
        Sb.Append('if(marker){marker.setPosition({lat:la,lng:ln});}');
        Sb.Append('else{marker=new google.maps.Marker({position:{lat:la,lng:ln},map:map,');
        Sb.Append('animation:google.maps.Animation.DROP});}');
        Sb.Append('map.panTo({lat:la,lng:ln});}');
        Sb.Append('function updateBar(){');
        Sb.Append('document.getElementById("coords").textContent=');
        Sb.Append('"Lat: "+selLat.toFixed(6)+"  |  Lng: "+selLng.toFixed(6);');
        Sb.Append('document.getElementById("badge").textContent="⚠️ Confirmez pour enregistrer";');
        Sb.Append('document.getElementById("badge").className="";');
        Sb.Append('document.getElementById("btn").disabled=false;}');
        Sb.Append('function confirmPos(){');
        Sb.Append('if(selLat===null)return;');
        Sb.Append('sendToBC(true);');
        Sb.Append('document.getElementById("badge").textContent="✅ Position confirmée";');
        Sb.Append('document.getElementById("badge").className="ok";');
        Sb.Append('document.getElementById("btn").disabled=true;}');
        Sb.Append('function sendToBC(confirmed){');
        Sb.Append('var p=JSON.stringify({type:"AGENCY_COORDS",lat:selLat,lng:selLng,confirmed:confirmed});');
        Sb.Append('if(typeof Microsoft!="undefined"&&Microsoft.Dynamics&&Microsoft.Dynamics.NAV)');
        Sb.Append('Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("CoordinatesSelected",[String(selLat),String(selLng),String(confirmed)]);');
        Sb.Append('if(window.parent!==window)window.parent.postMessage(p,"*");}');
        Sb.Append('function setCoords(la,ln){');
        Sb.Append('if(!la||!ln||la==="0"||ln==="0")return;');
        Sb.Append('var f=parseFloat(la),g=parseFloat(ln);');
        Sb.Append('map.setCenter({lat:f,lng:g});map.setZoom(15);moveMarker(f,g);');
        Sb.Append('document.getElementById("coords").textContent="Lat: "+f.toFixed(6)+"  |  Lng: "+g.toFixed(6);');
        Sb.Append('document.getElementById("badge").textContent="✅ Position actuelle";');
        Sb.Append('document.getElementById("badge").className="ok";}');
        Sb.Append('<\/script>');
        Sb.Append('<script src="https://maps.googleapis.com/maps/api/js?key=');
        Sb.Append(ApiKey);
        Sb.Append('&callback=initMap" async defer><\/script>');
        Sb.Append('</body></html>');

        exit(Sb.ToText());
    end;
}