var map,
  marker,
  selLat = null,
  selLng = null,
  selAddress = "";
var mapReady = false;
var pendingCoords = null;
var markerIcon = null;
function getMarkerIcon() {
  if (markerIcon) return markerIcon;

  markerIcon = L.divIcon({
    className: "custom-marker",
    html: `
            <div style="
                width: 30px;
                height: 30px;
                background: #e74c3c;
                border: 3px solid white;
                border-radius: 50% 50% 50% 0;
                transform: rotate(-45deg);
                box-shadow: 0 4px 8px rgba(0,0,0,0.3);
                position: relative;
            ">
                <div style="
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%) rotate(45deg);
                    color: white;
                    font-size: 14px;
                ">STA</div>
            </div>
        `,
    iconSize: [30, 30],
    iconAnchor: [15, 30],
    popupAnchor: [0, -30],
  });

  return markerIcon;
}

function initLeafletMap() {
  map = L.map("map").setView([36.8065, 10.1815], 12);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "© OpenStreetMap contributors",
    maxZoom: 19,
  }).addTo(map);

  map.on("click", function (e) {
    selLat = e.latlng.lat;
    selLng = e.latlng.lng;
    moveMarker(selLat, selLng);
    updateBar(false, "Recherche de l'adresse...");
    reverseGeocode(selLat, selLng);
  });

  mapReady = true;
  map.invalidateSize();

  if (pendingCoords) {
    applyCoordinates(pendingCoords.lat, pendingCoords.lng);
    pendingCoords = null;
  }
}

function reverseGeocode(lat, lng) {
  var url =
    "https://nominatim.openstreetmap.org/reverse?format=json&lat=" +
    lat +
    "&lon=" +
    lng;
  fetch(url)
    .then(function (r) {
      return r.json();
    })
    .then(function (data) {
      selAddress = data.display_name || "";
      updateBar(false);
      notifyBC(false);
    })
    .catch(function () {
      selAddress = "";
      updateBar(false);
      notifyBC(false);
    });
}

function moveMarker(lat, lng) {
  if (marker) {
    marker.setLatLng([lat, lng]);
  } else {
    marker = L.marker([lat, lng], { icon: getMarkerIcon() }).addTo(map);
  }
  map.panTo([lat, lng]);
}

function updateBar(confirmed, overrideText) {
  var badge = document.getElementById("badge");
  var coords = document.getElementById("coords");
  var btn = document.getElementById("btn");

  coords.textContent =
    overrideText ||
    "Lat: " +
      selLat.toFixed(6) +
      "  |  Lng: " +
      selLng.toFixed(6) +
      (selAddress ? "  |  " + selAddress : "");

  if (confirmed) {
    badge.textContent = "\u2705 Position confirmée";
    badge.className = "ok";
    btn.disabled = true;
  } else {
    badge.textContent = "\u26A0\uFE0F Cliquez sur Confirmer pour enregistrer";
    badge.className = "";
    btn.disabled = false;
  }
}

function confirmPos() {
  if (selLat === null) return;
  notifyBC(true);
  updateBar(true);
}

function notifyBC(confirmed) {
  if (
    typeof Microsoft !== "undefined" &&
    Microsoft.Dynamics &&
    Microsoft.Dynamics.NAV
  ) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
      "CoordinatesSelected",
      [selLat, selLng, confirmed, selAddress || ""],
      false
    );
  }
}

function applyCoordinates(lat, lng) {
  selLat = lat;
  selLng = lng;
  map.setView([lat, lng], 15);
  moveMarker(lat, lng);
  document.getElementById("coords").textContent =
    "Lat: " + lat.toFixed(6) + "  |  Lng: " + lng.toFixed(6);
  document.getElementById("badge").className = "ok";
  map.invalidateSize();
}

window.SetCoordinates = function (lat, lng) {
  lat = parseFloat(lat);
  lng = parseFloat(lng);
  if (!lat && !lng) return;

  if (!mapReady) {
    pendingCoords = { lat: lat, lng: lng };
    return;
  }
  applyCoordinates(lat, lng);
};
