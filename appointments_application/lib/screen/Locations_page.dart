import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../config/Palette.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  bool _isLoading = true;
  int? _selectedIndex;

  final List<Map<String, dynamic>> _agencyLocations = [
    {
      'name': 'Agence Centrale - Tunis',
      'address': 'Avenue Habib Bourguiba, Tunis',
      'lat': 36.8065,
      'lng': 10.1815,
    },
    {
      'name': 'Agence Lac',
      'address': 'Les Berges du Lac, Tunis',
      'lat': 36.8380,
      'lng': 10.2306,
    },
    {
      'name': 'Agence La Marsa',
      'address': 'La Marsa, Tunis',
      'lat': 36.8775,
      'lng': 10.3247,
    },
    {
      'name': 'Agence Sfax',
      'address': 'Centre Ville, Sfax',
      'lat': 34.7406,
      'lng': 10.7603,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        _fitAllMarkers(); // affiche toutes les agences même sans GPS
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        _fitAllMarkers();
        return;
      }
    }

    try {
      final userLocation = await location.getLocation();
      setState(() {
        _currentLocation = userLocation;
        _isLoading = false;
      });

      // ✅ Affiche TOUTES les agences + position utilisateur d'un coup
      _fitAllMarkers();

      location.onLocationChanged.listen((newLocation) {
        setState(() => _currentLocation = newLocation);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _fitAllMarkers();
    }
  }

  // ✅ Calcule les bounds pour englober TOUS les marqueurs et ajuste le zoom
  void _fitAllMarkers() {
    // Petite attente pour que le MapController soit prêt
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Collecte tous les points (agences + position actuelle si disponible)
      final List<LatLng> allPoints = _agencyLocations
          .map((loc) => LatLng(loc['lat'], loc['lng']))
          .toList();

      if (_currentLocation != null) {
        allPoints.add(LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ));
      }

      if (allPoints.isEmpty) return;

      // Calcule les limites min/max lat et lng
      double minLat = allPoints.first.latitude;
      double maxLat = allPoints.first.latitude;
      double minLng = allPoints.first.longitude;
      double maxLng = allPoints.first.longitude;

      for (final point in allPoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      // ✅ Crée les bounds et applique avec padding
      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60), // marge autour des marqueurs
        ),
      );
    });
  }

  List<Marker> _buildAgencyMarkers() {
    return List.generate(_agencyLocations.length, (index) {
      final isSelected = _selectedIndex == index;
      return Marker(
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        point: LatLng(
          _agencyLocations[index]['lat'],
          _agencyLocations[index]['lng'],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            setState(() => _selectedIndex = index);
            _showLocationInfo(_agencyLocations[index]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.location_on,
              color: isSelected ? Colors.orange : Colors.red,
              size: isSelected ? 55.0 : 45.0,
            ),
          ),
        ),
      );
    });
  }

  void _showLocationInfo(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.red, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      location['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location['address'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Bouton zoom sur ce local
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _mapController.move(
                          LatLng(location['lat'], location['lng']),
                          17.0,
                        );
                      },
                      icon: const Icon(Icons.zoom_in),
                      label: const Text('Voir en détail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.secondPageContainerGradient2ndColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bouton retour vue globale
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _fitAllMarkers(); // retour vue globale toutes agences
                      },
                      icon: const Icon(Icons.zoom_out_map),
                      label: const Text('Vue globale'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Palette.secondPageContainerGradient2ndColor,
                        side: BorderSide(
                          color: Palette.secondPageContainerGradient2ndColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() => _selectedIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locaux de l\'Agence'),
        backgroundColor: Palette.secondPageContainerGradient2ndColor,
        foregroundColor: Colors.white,
        actions: [
          // ✅ Bouton vue globale (toutes les agences)
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Voir toutes les agences',
            onPressed: _fitAllMarkers,
          ),
          if (_currentLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Ma position',
              onPressed: () {
                _mapController.move(
                  LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  14.0,
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Palette.secondPageContainerGradient2ndColor,
            ),
            const SizedBox(height: 16),
            const Text('Récupération de votre position...'),
          ],
        ),
      )
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(35.8, 10.0), // centre Tunisie
          initialZoom: 7.0, // zoom pour voir toute la Tunisie
          minZoom: 3.0,
          maxZoom: 19.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
          onTap: (_, __) => setState(() => _selectedIndex = null),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.STA.appointments_application',
            additionalOptions: const {
              'User-Agent': 'appointments_application/1.0',
            },
            maxNativeZoom: 19,
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [
              // Marqueur position actuelle (bleu)
              if (_currentLocation != null)
                Marker(
                  width: 50,
                  height: 50,
                  point: LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
              // Marqueurs agences (rouge)
              ..._buildAgencyMarkers(),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Boutons zoom + et -
            FloatingActionButton.small(
              heroTag: 'zoom_in',
              onPressed: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'zoom_out',
              onPressed: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 8),
            // Bouton Tous les locaux
            FloatingActionButton.extended(
              heroTag: 'list',
              onPressed: () => _showAllLocations(),
              backgroundColor: Palette.secondPageContainerGradient2ndColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.list),
              label: const Text('Tous les locaux'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllLocations() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Locaux de l\'Agence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _agencyLocations.length,
              itemBuilder: (context, index) {
                final loc = _agencyLocations[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(loc['name']),
                  subtitle: Text(loc['address']),
                  trailing: const Icon(Icons.zoom_in, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = index);
                    _mapController.move(
                      LatLng(loc['lat'], loc['lng']),
                      17.0,
                    );
                    _showLocationInfo(loc);
                  },
                );
              },
            ),

          ],
        );

      },

    );

  }
}