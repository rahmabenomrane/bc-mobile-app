controladdin AgencyMapPicker
{
    Scripts =
        'src/Ressources/JS/leaflet.js',
        'src/Ressources/JS/main.js';

    StyleSheets =
        'src/Ressources/CSS/leaflet.css',
        'src/Ressources/CSS/style.css';

    StartupScript = 'src/Ressources/JS/startup.js';
    Images ='src/Ressources/images/marker.png';
    RequestedHeight = 500;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    event ControlAddInReady();
    event CoordinatesSelected(Lat: Decimal; Lng: Decimal; Confirmed: Boolean; Address: Text);

    procedure SetCoordinates(Lat: Decimal; Lng: Decimal);
}