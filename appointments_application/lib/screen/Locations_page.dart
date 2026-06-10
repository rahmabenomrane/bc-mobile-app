import 'dart:convert';

import 'package:appointments_application/screen/service_selection_screen.dart';
import 'package:appointments_application/screen/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../Service/agency_service.dart';
import '../config/Palette.dart';
import '../models/agency_model.dart';
import '../models/vehicle_model.dart';

class MapScreen extends StatefulWidget {
  final Vehicle selectedVehicle;

  const MapScreen({super.key, required this.selectedVehicle});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LocationData? _currentLocation;

  final AgencyService _agencyService = AgencyService();
  List<Agency> _agencies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
    _getCurrentLocation();
  }

  // ── Chargement des agences ─────────────────────────────────────────────────

  Future<void> _loadAgencies() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }
    try {
      final agencies = await _agencyService.getAgencies();

      for (var agency in agencies) {

        if (agency.latitude is String) {
          agency.latitude = double.tryParse(agency.latitude.toString().replaceAll(',', '.'));
        }
        if (agency.longitude is String) {
          agency.longitude = double.tryParse(agency.longitude.toString().replaceAll(',', '.'));
        }

        if (agency.latitude != null) {
          agency.latitude = double.parse(agency.latitude!.toStringAsFixed(6));
        }
        if (agency.longitude != null) {
          agency.longitude = double.parse(agency.longitude!.toStringAsFixed(6));
        }

        print('✅ Agence chargée: ${agency.name} - Lat: ${agency.latitude}, Lng: ${agency.longitude}');
      }

      setState(() { _agencies = agencies; _isLoading = false; });

      // Attendre que le widget soit construit avant de centrer la carte
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitAllMarkers();
      });
    } catch (e) {
      print('❌ Erreur: $e');
      if (e.toString().contains("401") ||
          e.toString().contains("Session expirée")) {
        _showSessionExpiredDialog();
      } else {
        setState(() { _errorMessage = e.toString(); _isLoading = false; });
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session expirée"),
        content: const Text("Votre session a expiré. Veuillez vous reconnecter."),
        actions: [
          TextButton(
            onPressed: () {
              const FlutterSecureStorage().delete(key: "token");
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text("Reconnecter"),
          ),
        ],
      ),
    );
  }

  // ── Localisation ───────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) { _fitAllMarkers(); return; }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _fitAllMarkers();
        return;
      }
    }

    try {
      final userLocation = await location.getLocation();
      setState(() => _currentLocation = userLocation);
      _fitAllMarkers();
      location.onLocationChanged.listen((l) {
        if (mounted) setState(() => _currentLocation = l);
      });
    } catch (_) {
      _fitAllMarkers();
    }
  }

  // ── Carte ──────────────────────────────────────────────────────────────────

  void _fitAllMarkers() {
    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _agencies.isEmpty) return;

      final allPoints = <LatLng>[];

      // Ajouter les agences avec coordonnées valides
      for (var agency in _agencies) {
        if (agency.latitude != null && agency.longitude != null) {
          try {
            final point = LatLng(agency.latitude!, agency.longitude!);
            allPoints.add(point);
            print('📍 Point ajouté: ${agency.name} - ${point.latitude}, ${point.longitude}');
          } catch (e) {
            print('❌ Erreur coordonnées pour ${agency.name}: $e');
          }
        }
      }

      if (_currentLocation != null) {
        allPoints.add(LatLng(
            _currentLocation!.latitude!, _currentLocation!.longitude!));
      }

      if (allPoints.isEmpty) {
        print('⚠️ Aucun point valide à afficher');
        // Centre par défaut sur Tunis
        _mapController.move(const LatLng(36.819, 10.1658), 12.0);
        return;
      }

      double minLat = allPoints.first.latitude, maxLat = allPoints.first.latitude;
      double minLng = allPoints.first.longitude, maxLng = allPoints.first.longitude;

      for (final p in allPoints) {
        if (p.latitude  < minLat) minLat = p.latitude;
        if (p.latitude  > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(
                LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
            padding: const EdgeInsets.all(60),
          ),
        );
        print('✅ Carte centrée sur ${allPoints.length} points');
      } catch (e) {
        print('❌ Erreur fitCamera: $e');
        _mapController.move(const LatLng(36.819, 10.1658), 12.0);
      }
    });
  }

  // ── Déterminer la couleur de disponibilité ──
  Color _getAvailabilityColor(Agency agency) {
    // Adaptez selon vos données
    // Pour l'exemple, je mets toutes les agences en vert
    // À modifier selon votre logique métier
    return Colors.green;

    // Exemple avec la capacité :
    // final capacity = agency.capacity ?? 50;
    // if (capacity > 70) return Colors.green;
    // if (capacity > 30) return Colors.orange;
    // return Colors.red;
  }

  List<Marker> _buildAgencyMarkers() {
    final markers = <Marker>[];

    for (int index = 0; index < _agencies.length; index++) {
      final agency = _agencies[index];

      // Vérification stricte
      if (agency.latitude == null || agency.longitude == null) {
        print('⚠️ ${agency.name}: coordonnées nulles');
        continue;
      }

      // Vérifier que ce sont des nombres valides
      double lat, lng;
      try {
        lat = agency.latitude is double ? agency.latitude! : double.parse(agency.latitude.toString());
        lng = agency.longitude is double ? agency.longitude! : double.parse(agency.longitude.toString());

        if (lat.isNaN || lng.isNaN || lat == 0.0 || lng == 0.0) {
          print('⚠️ ${agency.name}: coordonnées invalides ($lat, $lng)');
          continue;
        }
      } catch (e) {
        print('❌ ${agency.name}: erreur conversion coordonnées - $e');
        continue;
      }


      print('✅ Création marqueur: ${agency.name} à ($lat, $lng)');

      final isSelected = _selectedIndex == index;
      final availabilityColor = _getAvailabilityColor(agency);
       markers.add(
        Marker(
          width: isSelected ? 56 : 44,
          height: isSelected ? 70 : 56,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () {
              print('🖱️ Clic sur ${agency.name}');
              setState(() => _selectedIndex = index);
              _showLocationInfo(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _AgencyPin(
                isSelected: isSelected,
                availabilityColor: availabilityColor,
              ),
            ),
          ),
        ),
      );
    }

    print('📊 Total marqueurs: ${markers.length}/${_agencies.length}');
    return markers;
  }

  void _navigateToServiceSelection(Agency agency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceSelectionScreen(
          selectedVehicle: widget.selectedVehicle,
          selectedAgency: agency.toMap(),
        ),
      ),
    );
  }

  void _showLocationInfo(int index) {
    final agency = _agencies[index];

    if (agency.latitude == null || agency.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordonnées de l\'agence indisponibles')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AgencyDetailSheet(
        agency: agency,
        availabilityColor: _getAvailabilityColor(agency),
        onZoom: () {
          Navigator.pop(context);
          if (agency.latitude != null && agency.longitude != null) {
            _mapController.move(LatLng(agency.latitude!, agency.longitude!), 17.0);
          }
        },
        onBook: () {
          Navigator.pop(context);
          _navigateToServiceSelection(agency);
        },
        onGlobalView: () {
          Navigator.pop(context);
          _fitAllMarkers();
        },
      ),
    ).whenComplete(() => setState(() => _selectedIndex = null));
  }

  void _showAllLocations() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AllLocationsSheet(
        agencies: _agencies,
        getAvailabilityColor: _getAvailabilityColor,
        onSelect: (index) {
          Navigator.pop(context);
          setState(() => _selectedIndex = index);
          final agency = _agencies[index];
          if (agency.latitude != null && agency.longitude != null) {
            _mapController.move(LatLng(agency.latitude!, agency.longitude!), 17.0);
          }
          _showLocationInfo(index);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Palette.secondPageContainerGradient2ndColor,
        foregroundColor: Palette.secondPageIconColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nos agences',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Palette.secondPageTitleColor,
              ),
            ),
            Text(
              '${_agencies.length} locaux disponibles',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map_rounded, size: 20),
            tooltip: 'Voir toutes les agences',
            onPressed: _fitAllMarkers,
          ),
          if (_currentLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location_rounded, size: 20),
              tooltip: 'Ma position',
              onPressed: () => _mapController.move(
                LatLng(_currentLocation!.latitude!,
                    _currentLocation!.longitude!),
                14.0,
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            color: Palette.secondPageContainerGradient2ndColor,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Column(
              children: [
                StepIndicator(currentStep: 2, totalSteps: 5),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StepLabel('Véhicule',     active: false, done: true),
                    _StepLabel('Agence',       active: true,  done: false),
                    _StepLabel('Service',      active: false, done: false),
                    _StepLabel('Créneau',      active: false, done: false),
                    _StepLabel('Confirmation', active: false, done: false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoader()
          : _errorMessage.isNotEmpty
          ? _buildError()
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(36.819, 10.1658), // Tunis centre
          initialZoom: 12.0,
          minZoom: 3.0,
          maxZoom: 19.0,
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all),
          onTap: (_, __) =>
              setState(() => _selectedIndex = null),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
            'com.STA.appointments_application',
            additionalOptions: const {
              'User-Agent': 'appointments_application/1.0'
            },
            maxNativeZoom: 19,
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [
              if (_currentLocation != null)
                Marker(
                  width: 48,
                  height: 48,
                  point: LatLng(_currentLocation!.latitude!,
                      _currentLocation!.longitude!),
                  child: const _MyLocationPin(),
                ),
              ..._buildAgencyMarkers(),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFABs(),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: Palette.secondPageContainerGradient2ndColor),
          const SizedBox(height: 16),
          Text('Chargement des agences...',
              style: GoogleFonts.dmSans(color: Palette.textColor1)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: Palette.textColor1)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAgencies,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.secondPageContainerGradient2ndColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Réessayer',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFABs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MapFAB(
            icon: Icons.add_rounded,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(width: 8),
          _MapFAB(
            icon: Icons.remove_rounded,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'list',
            onPressed: _showAllLocations,
            backgroundColor: Palette.secondPageContainerGradient2ndColor,
            foregroundColor: Palette.secondPageIconColor,
            elevation: 4,
            icon: const Icon(Icons.list_rounded, size: 20),
            label: Text(
              'Tous les locaux',
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Widgets auxiliaires ──────────────────────────────────────────────────────

class _AgencyPin extends StatelessWidget {
  final bool isSelected;
  final Color availabilityColor; // Nouvelle propriété

  const _AgencyPin({
    required this.isSelected,
    required this.availabilityColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 52.0 : 40.0;

    if (isSelected) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: availabilityColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: availabilityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: availabilityColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.business_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Container(
            width: 4, height: 4,
            decoration: BoxDecoration(
              color: availabilityColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: availabilityColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: availabilityColor.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.business_rounded,
              color: Colors.white, size: 18),
        ),
        Container(
          width: 4, height: 4,
          decoration: BoxDecoration(
            color: availabilityColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _MyLocationPin extends StatelessWidget {
  const _MyLocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.secondPageContainerGradient2ndColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: Palette.secondPageContainerGradient2ndColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.navigation_rounded,
              color: Colors.white, size: 14),
        ),
      ),
    );
  }
}

class _MapFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapFAB({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Palette.secondPageIconColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Palette.textColor1.withOpacity(0.12), blurRadius: 8)
          ],
        ),
        child: Icon(icon, color: Palette.homePageTitle, size: 20),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String text;
  final bool active;
  final bool done;
  const _StepLabel(this.text, {required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: active
            ? Colors.white
            : done
            ? Colors.white54
            : Colors.white38,
      ),
    );
  }
}

// ─── Bottom sheets ─────────────────────────────────────────────────────────────

class _AgencyDetailSheet extends StatelessWidget {
  final Agency agency;
  final Color availabilityColor;
  final VoidCallback onZoom;
  final VoidCallback onBook;
  final VoidCallback onGlobalView;

  const _AgencyDetailSheet({
    required this.agency,
    required this.availabilityColor,
    required this.onZoom,
    required this.onBook,
    required this.onGlobalView,
  });

  String _getAvailabilityText() {
    if (availabilityColor == Colors.green) return 'Disponibilité élevée';
    if (availabilityColor == Colors.orange) return 'Disponibilité moyenne';
    return 'Disponibilité faible';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: Palette.secondPageIconColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Palette.textColor1.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 16),
              decoration: BoxDecoration(
                color: Palette.textColor1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête agence avec indicateur de disponibilité
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: availabilityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.business_rounded,
                          color: availabilityColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agency.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Palette.homePageTitle,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12, color: Palette.textColor1),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  agency.address,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Palette.textColor1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Indicateur de disponibilité
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: availabilityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: availabilityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getAvailabilityText(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: availabilityColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Stats
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Palette.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [

                      _StatChip(
                        icon: Icons.access_time_rounded,
                        label: agency.officeHours.isEmpty
                            ? 'N/D'
                            : agency.officeHours,
                        iconColor: Colors.grey.shade600,
                      ),
                      const _Divider(),
                      _StatChip(
                        icon: Icons.phone_rounded,
                        label: agency.phoneNo.isEmpty
                            ? 'N/D'
                            : agency.phoneNo,
                        iconColor: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onBook,
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: Text(
                      'Prendre rendez-vous',
                      style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availabilityColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onZoom,
                        icon: const Icon(Icons.zoom_in_rounded, size: 16),
                        label: Text('Voir sur carte',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: availabilityColor,
                          side: BorderSide(color: availabilityColor, width: 1),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGlobalView,
                        icon: const Icon(Icons.zoom_out_map_rounded,
                            size: 16),
                        label: Text('Vue globale',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Palette.textColor1,
                          side: BorderSide(
                              color: Palette.textColor1.withOpacity(0.3),
                              width: 1),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllLocationsSheet extends StatelessWidget {
  final List<Agency> agencies;
  final Color Function(Agency) getAvailabilityColor;
  final void Function(int index) onSelect;

  const _AllLocationsSheet({
    required this.agencies,
    required this.getAvailabilityColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: Palette.secondPageIconColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Palette.textColor1.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: Palette.textColor1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(
              children: [
                Text(
                  'Toutes nos agences',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Palette.homePageTitle,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.secondPageContainerGradient2ndColor
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${agencies.length} locaux',
                    style: TextStyle(
                      fontSize: 11,
                      color: Palette.secondPageContainerGradient2ndColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agencies.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Palette.backgroundColor,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (_, index) {
              final agency = agencies[index];
              final availabilityColor = getAvailabilityColor(agency);

              return InkWell(
                onTap: () => onSelect(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: availabilityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.business_rounded,
                            color: availabilityColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agency.name,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Palette.homePageTitle,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              agency.address,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Palette.textColor1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: availabilityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            agency.officeHours.isEmpty
                                ? 'N/D'
                                : agency.officeHours,
                            style: TextStyle(
                                fontSize: 10,
                                color: Palette.textColor1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Micro widgets ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  const _StatChip(
      {required this.icon,
        required this.label,
        required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Palette.homePageTitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: Palette.backgroundColor);
  }
}