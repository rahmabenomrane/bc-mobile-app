import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/claim_model.dart';
import '../Service/vehicle_service.dart';
import '../models/Appontment_model.dart';
import '../models/vehicle_model.dart';
import 'claims_list_screen.dart';

class CreateClaimScreen extends StatefulWidget {
  const CreateClaimScreen({super.key});

  @override
  State<CreateClaimScreen> createState() => _CreateClaimScreenState();
}

class _CreateClaimScreenState extends State<CreateClaimScreen> {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = "http://127.0.0.1:5032";

  final _vehicleService = VehicleService();
  final _formKey        = GlobalKey<FormState>();
  final _descController = TextEditingController();

  // Véhicules
  List<Vehicle> _vehicles       = [];
  Vehicle?      _selectedVehicle;
  bool          _loadingVehicles = true;
  String?       _vehiclesError;

  // RDV
  List<AppointmentModel> _appointments      = [];
  AppointmentModel?      _selectedAppointment;
  bool                   _loadingRdv = true;
  String?                _rdvError;

  // Soumission
  int     _priority   = 1;
  bool    _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadAppointments();
  }

  // ── Véhicules — votre pattern exact ─────────────────────────
  Future<void> _loadVehicles() async {
    setState(() { _loadingVehicles = true; _vehiclesError = null; });
    try {
      final vehicles = await _vehicleService.getMyVehicles();
      setState(() => _vehicles = vehicles);
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Session expirée')) {
        _showSessionExpiredDialog();
      } else {
        setState(() => _vehiclesError = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loadingVehicles = false);
    }
  }

  // ── RDV — clé "customerNumber" identique à votre AuthService ─
  Future<void> _loadAppointments() async {
    setState(() { _loadingRdv = true; _rdvError = null; });
    try {
      final customerNumber = await _storage.read(key: "customerNumber");
      if (customerNumber == null) throw Exception("Session expirée.");

      final response = await http.get(
        Uri.parse("$_baseUrl/api/Appointment/customer/$customerNumber"),
      );

      print("[RDV] Status → ${response.statusCode}");
      print("[RDV] Body   → ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;
        final all = data
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        // confirmed + pending seulement
        setState(() => _appointments = all.where((rdv) {
          final s = (rdv.status ?? '').toLowerCase();
          return s == 'confirmed' || s == 'pending';
        }).toList());
      } else if (response.statusCode == 401) {
        _showSessionExpiredDialog();
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => _rdvError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingRdv = false);
    }
  }

  // ── Soumission ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicle == null) {
      setState(() => _submitError = 'Veuillez sélectionner un véhicule.');
      return;
    }
    setState(() { _submitting = true; _submitError = null; });
    try {

      final token = await _storage.read(key: "token");
      print("[CLAIM] TOKEN = $token");
      if (token == null) { _showSessionExpiredDialog(); return; }

      final body = jsonEncode({
        'vehicleNo':      _selectedVehicle!.numVehicle,
        'registrationNumber': _selectedVehicle!.registrationNumber ?? '',
        'description':    _descController.text.trim(),
        'priority':       _priority,
        'appointmentRef': _selectedAppointment?.appointmentNo ?? '',
      });

      print("[CLAIM] POST /api/claims → $body");

      final response = await http.post(
        Uri.parse("$_baseUrl/api/claims"),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );


      print("[CLAIM] Status → ${response.statusCode}");
      print("[CLAIM] Body   → ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> json = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : decoded as Map<String, dynamic>;

        final claim = ClaimModel.fromJson(json);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Réclamation #${claim.claimNumber} créée avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ClaimsListScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _submitError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session expirée'),
        content: const Text('Veuillez vous reconnecter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Nouvelle réclamation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // 1. VÉHICULE
            _SectionTitle(icon: Icons.directions_car_rounded, label: 'Véhicule concerné *'),
            const SizedBox(height: 12),
            _buildVehiclesSection(),
            const SizedBox(height: 24),

            // 2. RDV
            _SectionTitle(icon: Icons.event_rounded, label: 'Rendez-vous concerné'),
            const SizedBox(height: 4),
            Text('Sélectionnez le RDV lié à cette réclamation.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            _buildRdvSection(),
            const SizedBox(height: 24),

            // 3. DESCRIPTION
            _SectionTitle(icon: Icons.edit_note_rounded, label: 'Description du réclamation *'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              maxLength: 100,
              decoration: _inputDeco('Décrivez le problème constaté...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La description est obligatoire.';
                if (v.trim().length < 10) return 'Minimum 10 caractères.';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 4. PRIORITÉ
            _SectionTitle(icon: Icons.flag_rounded, label: 'Priorité'),
            const SizedBox(height: 12),
            _PriorityPicker(value: _priority, onChanged: (p) => setState(() => _priority = p)),
            const SizedBox(height: 28),

            // Erreur
            if (_submitError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF09595)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Color(0xFFA32D2D), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_submitError!,
                      style: const TextStyle(color: Color(0xFFA32D2D), fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA32D2D),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(height: 22, width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Soumettre la réclamation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesSection() {
    if (_loadingVehicles) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator()));
    if (_vehiclesError != null) return _ErrorRetry(message: 'Impossible de charger les véhicules.', onRetry: _loadVehicles);
    if (_vehicles.isEmpty) return const _EmptyBox(label: 'Aucun véhicule sur votre compte.');
    return Column(children: _vehicles.map((v) => _VehicleCard(
      vehicle: v,
      isSelected: _selectedVehicle?.numVehicle == v.numVehicle,
      onTap: () => setState(() { _selectedVehicle = v; _selectedAppointment = null; }),
    )).toList());
  }

  Widget _buildRdvSection() {
    // Aucun véhicule sélectionné → invitation à choisir d'abord
    if (_selectedVehicle == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade400, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Sélectionnez d\'abord un véhicule pour voir les rendez-vous associés.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ]),
      );
    }

    if (_loadingRdv) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator()));
    if (_rdvError != null) return _ErrorRetry(message: 'Impossible de charger les rendez-vous.', onRetry: _loadAppointments);

    // Filtre par numVehicle du véhicule sélectionné
    final filtered = _appointments
        .where((rdv) => rdv.numVehicle == _selectedVehicle!.numVehicle)
        .toList();

    if (filtered.isEmpty) {
      return _EmptyBox(
        label: 'Aucun rendez-vous trouvé pour ${_selectedVehicle!.fullName}.',
      );
    }

    return Column(children: filtered.map((rdv) => _RdvCard(
      appointment: rdv,
      isSelected: _selectedAppointment?.appointmentNo == rdv.appointmentNo,
      onTap: () => setState(() {
        _selectedAppointment =
        _selectedAppointment?.appointmentNo == rdv.appointmentNo ? null : rdv;
      }),
    )).toList());
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  @override
  void dispose() { _descController.dispose(); super.dispose(); }
}

// ── Card Véhicule ────────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  const _VehicleCard({required this.vehicle, required this.isSelected, required this.onTap});

  String get _fuelLabel { switch (vehicle.motorisation) { case '0': return 'Essence'; case '1': return 'Diesel'; case '2': return 'Hybride'; case '3': return 'Électrique'; default: return ''; } }
  IconData get _fuelIcon { switch (vehicle.motorisation) { case '2': return Icons.bolt_rounded; case '3': return Icons.electric_car_rounded; default: return Icons.local_gas_station_rounded; } }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCEBEB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFA32D2D) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFA32D2D).withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.directions_car_rounded,
                color: isSelected ? const Color(0xFFA32D2D) : Colors.grey.shade500, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vehicle.fullName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                color: isSelected ? const Color(0xFFA32D2D) : Colors.black87)),
            const SizedBox(height: 4),
            Row(children: [
              if (vehicle.registrationNumber != null && vehicle.registrationNumber!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
                  child: Text(vehicle.registrationNumber!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                const SizedBox(width: 8),
              ],
              Icon(_fuelIcon, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(_fuelLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ]),
          ])),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSelected
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFFA32D2D), size: 22, key: ValueKey('checked'))
                : Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade300, size: 22, key: ValueKey('unchecked')),
          ),
        ]),
      ),
    );
  }
}

// ── Card RDV ─────────────────────────────────────────────────
class _RdvCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isSelected;
  final VoidCallback onTap;
  const _RdvCard({required this.appointment, required this.isSelected, required this.onTap});

  String _fmt(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.hour.toString().padLeft(2,'0')}h${d.minute.toString().padLeft(2,'0')}';
    } catch(_) { return iso; }
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
    } catch(_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event_rounded,
                color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.AgencyName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF1565C0) : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Utiliser serviceDescription au lieu de serviceCode
                  Text(
                    appointment.serviceDescription.isNotEmpty
                        ? appointment.serviceDescription
                        : appointment.serviceCode, // Fallback sur le code si description vide
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Date et heure
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            _fmtDate(appointment.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${_fmt(appointment.StartTime)} → ${_fmt(appointment.EndTime)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sélection
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF1565C0),
                    size: 20,
                    key: ValueKey('checked'),
                  )
                      : Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: Colors.grey.shade300,
                    size: 20,
                    key: ValueKey('unchecked'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}class _SectionTitle extends StatelessWidget {
  final IconData icon; final String label;
  const _SectionTitle({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: const Color(0xFFA32D2D)),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
  ]);
}

class _ErrorRetry extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)),
    child: Row(children: [
      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: TextStyle(color: Colors.orange.shade800))),
      TextButton(onPressed: onRetry, child: const Text('Réessayer')),
    ]),
  );
}

class _EmptyBox extends StatelessWidget {
  final String label;
  const _EmptyBox({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
  );
}

class _PriorityPicker extends StatelessWidget {
  final int value; final ValueChanged<int> onChanged;
  const _PriorityPicker({required this.value, required this.onChanged});
  static const _opts = [
    (0, 'Faible', Icons.keyboard_double_arrow_down_rounded, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
    (1, 'Moyen',  Icons.remove_rounded,                     Color(0xFFF57F17), Color(0xFFFFF8E1)),
    (2, 'Élevé',  Icons.keyboard_double_arrow_up_rounded,   Color(0xFFC62828), Color(0xFFFCEBEB)),
  ];
  @override
  Widget build(BuildContext context) => Row(
    children: _opts.map((opt) {
      final (val, label, icon, color, bg) = opt;
      final sel = value == val;
      return Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => onChanged(val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: sel ? bg : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 2 : 1),
            ),
            child: Column(children: [
              Icon(icon, color: sel ? color : Colors.grey.shade400, size: 22),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.normal, color: sel ? color : Colors.grey.shade500)),
            ]),
          ),
        ),
      ));
    }).toList(),
  );
}