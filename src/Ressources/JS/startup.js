var container = document.getElementById("controlAddIn") || document.body;
var bar = document.createElement("div");
bar.id = "bar";
bar.innerHTML =
  '<span id="badge">\uD83D\uDCCD Cliquez sur la carte pour positionner l\'agence</span>' +
  '<div id="coords">Aucune coordonn\u00E9e s\u00E9lectionn\u00E9e</div>' +
  '<button id="btn" disabled onclick="confirmPos()"> Confirmer</button>';

var mapDiv = document.createElement("div");
mapDiv.id = "map";

container.appendChild(bar);
container.appendChild(mapDiv);

setTimeout(function () {
  initLeafletMap();
}, 300);
console.log("Images disponibles :");
console.log(
  "marker.png ->",
  Microsoft.Dynamics.NAV.GetImageResource("marker.png")
);
if (
  typeof Microsoft !== "undefined" &&
  Microsoft.Dynamics &&
  Microsoft.Dynamics.NAV
) {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "ControlAddInReady",
    [],
    false
  );
}
