import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../Service/appointment_service.dart';
import '../Service/auth_service.dart';
import '../config/Palette.dart';
import '../models/Appontment_model.dart';
import '../models/service_model.dart';
import '../models/vehicle_model.dart';
import 'confirmation_screen.dart';
import 'error_toast.dart';
import 'step_indicator.dart';

class AppointmentSlotScreen extends StatefulWidget {

  final String mode;
  final Vehicle? selectedVehicle;
  final Map<String, dynamic>? selectedAgency;
  final ServiceModel? selectedService;


  final Map<String, dynamic>? existingAppointment;
  const AppointmentSlotScreen({
    super.key,
    required this.mode,
    this.selectedVehicle,
    this.selectedAgency,
    this.selectedService,
    this.existingAppointment,
  });


  @override
  State<AppointmentSlotScreen> createState() => _AppointmentSlotScreenState();
}

class _AppointmentSlotScreenState extends State<AppointmentSlotScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _customerNumber;
  List<AppointmentModel> _appointments = [];
  String? _selectedSlot;
  String get agencyCode {
    return widget.selectedAgency?['code'] ??
        widget.existingAppointment?['agencyCode'] ??
        '';
  }
  String? _lastCreatedAppointmentNo;
  String? _customerEmail;
  String get vehicleNumber {
    if (widget.mode == "reschedule") {
      print("reschedule");
      print(widget.existingAppointment);
      return widget.existingAppointment?["numVehicle"]?.toString() ?? "";
    }

    return widget.selectedVehicle?.numVehicle ?? "";
  }
  String get serviceCode {
    return widget.selectedService?.code ??
        widget.existingAppointment?['serviceCode'] ??
        '';
  }

  Vehicle? get vehicle {
    if (widget.mode == "reschedule") return null;
    return widget.selectedVehicle;
  }

  @override
  void initState() {
    super.initState();
    void checkRequiredData() {
      if (widget.mode == "create") {
        assert(widget.selectedVehicle != null);
        assert(widget.selectedAgency != null);
        assert(widget.selectedService != null);
      }

      if (widget.mode == "reschedule") {
        assert(widget.existingAppointment != null);
        print("appppppp");
        print(widget.existingAppointment.toString());
         }
    }
    Future<void> loadCustomerNumber() async {
      final cn = await AuthService.storage.read(key: "customerNumber");
      setState(() => _customerNumber = cn);
      final em = await AuthService.storage.read(key: "customerEmail"); // ✅
      if (mounted) {
        setState(() {
        _customerNumber = cn;
        _customerEmail = em;
      });
      }
    }
    initializeDateFormatting('fr_FR', null);
    loadCustomerNumber();
    checkRequiredData();
    _loadAppointments();
    if (widget.mode == "reschedule" && widget.existingAppointment != null) {
      final appt = widget.existingAppointment!;
      _selectedDay = DateTime.parse(
        appt["date"],
      );

      _selectedSlot =
          appt["startTime"].toString();
    }
  }

  Future<void> _loadAppointments() async {
    final data = await AppointmentService.getAppointments(
      agencyCode,
      serviceCode,
    );
   setState(() {
      _appointments = data;
    });
  }
  bool get _canContinue =>
      _selectedDay != null && _selectedSlot != null;

  List<AppointmentModel> get _slotsForSelectedDay {
    if (_selectedDay == null) return [];

    return _appointments.where((a) {
      final d = DateTime.parse(a.date);

      return d.year == _selectedDay!.year &&
          d.month == _selectedDay!.month &&
          d.day == _selectedDay!.day;
    }).toList();
  }

  Map<String, int> parseOfficeHours(String officeHours) {
    try {
      final parts = officeHours.split('-');

      final start = int.parse(parts[0].replaceAll('h', '').trim());
      final end = int.parse(parts[1].replaceAll('h', '').trim());

      return {
        "open": start,
        "close": end,
      };
    } catch (e) {
      return {
        "open": 9,
        "close": 18,
      };
    }
  }

  List<String> generateSlots(DateTime day, String officeHours) {
    final hours = parseOfficeHours(officeHours);

    final open = hours["open"]!;
    final close = hours["close"]!;

    List<String> slots = [];

    for (int h = open; h < close; h++) {
      slots.add("${h.toString().padLeft(2, '0')}:00");
    }

    return slots;
  }

  List<Map<String, dynamic>> getDaySlots(DateTime day) {
    if (day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday) {
      return [];
    }

    final officeHours =
        widget.selectedAgency?['OfficeHours'] ?? "9h-18h";
    final slots = generateSlots(day, officeHours);

    return slots.map((time) {
      final taken = isSlotTaken(day, time);

      return {
        "time": time,
        "available": !taken,
      };
    }).toList();
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    return _appointments.where((a) {
      final d = DateTime.tryParse(a.StartTime);
      if (d == null) return false;
      return isSameDay(d, day);
    }).toList();
  }

// ✅ Slots désactivés si déjà pris
  bool isSlotTaken(DateTime day, String time) {
    return _appointments.any((a) {
      final d = DateTime.tryParse(a.StartTime);
      if (d == null) {

        return false;
      }
      final slotHour = "${d.hour.toString().padLeft(2, '0')}:00";
     return isSameDay(d, day) && slotHour == time;
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildCalendarCard(),
                  if (_selectedDay != null) ...[
                    const SizedBox(height: 4),
                    _buildSlotsSection(),
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _canContinue ? _buildCTA() : null,
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Palette.gradientFirst, Palette.gradientSecond],
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.gradientFirst.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Choisir un créneau",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StepIndicator(currentStep: 4, totalSteps: 5),
          const SizedBox(height: 6),

          // Labels étapes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepLabel('Véhicule',     done: false, active: true),
              _StepLabel('Agence',       done: false, active: false),
              _StepLabel('Service',      done: false, active: false),
              _StepLabel('Créneau',      done: false, active: false),
              _StepLabel('Confirmation', done: false, active: false),
            ],
          ),

        ],
      ),
    );
  }

  // ================= CALENDAR CARD =================
  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildCalendar(),
      ),
    );
  }

  // ================= CALENDAR =================
  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'fr_FR', // 🇫🇷 Calendrier en français
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,

      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedSlot = null;
        });
      },

      eventLoader: _getEventsForDay,

      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: 0.2,
        ),
        leftChevronIcon: Icon(Icons.chevron_left_rounded,
            color: Palette.gradientFirst, size: 24),
        rightChevronIcon: Icon(Icons.chevron_right_rounded,
            color: Palette.gradientFirst, size: 24),
        headerPadding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEF5), width: 1),
          ),
        ),
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9EBF),
        ),
        weekendStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFCFCFDE),
        ),
      ),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D2D4E),
        ),
        weekendTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: const Color(0xFFBBBBCC),
        ),
        disabledTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: const Color(0xFFDDDDEA),
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
        ),
        todayTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.orange.shade700,
        ),
        selectedDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.gradientFirst, Palette.gradientSecond],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Palette.gradientFirst.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        selectedTextStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.orange.shade400,
          shape: BoxShape.circle,
        ),
        markerSize: 5,
        cellMargin: const EdgeInsets.all(5),
      ),

      calendarBuilders: CalendarBuilders(
        // Marquer les weekends visuellement
        defaultBuilder: (context, day, focusedDay) {
          if (day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday) {
            return Center(
              child: Text(
                '${day.day}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: const Color(0xFFCCCCDD),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }


  // ================= SLOTS SECTION =================
  Widget _buildSlotsSection() {
    final slots = getDaySlots(_selectedDay!);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Palette.gradientFirst.withOpacity(0.15),
                        Palette.gradientSecond.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.access_time_rounded,
                      color: Palette.gradientFirst, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Créneaux disponibles",
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      _formatSelectedDay(),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF9E9EBF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEF5)),
          const SizedBox(height: 12),

          if (slots.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Icon(Icons.block_rounded, color: Colors.red.shade300, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Agence fermée ce jour",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildSlots(slots),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _formatSelectedDay() {
    if (_selectedDay == null) return '';
    const jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final d = _selectedDay!;
    return "${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}";
  }

  // ================= SLOTS =================
  Widget _buildSlots(List<Map<String, dynamic>> slots) {
    final available = slots.where((s) => s["available"] == true).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              "$available créneaux libres",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF9E9EBF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),


          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final slot = slots[i];
              final isSelected = _selectedSlot == slot["time"];
              final isAvailable = slot["available"] as bool;

              return GestureDetector(
                onTap: isAvailable
                    ? () => setState(() => _selectedSlot = slot["time"])
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        Palette.gradientFirst,
                        Palette.gradientSecond
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected
                        ? null
                        : isAvailable
                        ? const Color(0xFFF4F6FB)
                        : const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isAvailable
                          ? const Color(0xFFDDDDEA)
                          : const Color(0xFFEAEAF0),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Palette.gradientFirst.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isAvailable)
                          Icon(Icons.close_rounded,
                              size: 12,
                              color: const Color(0xFFBBBBCC))
                        else
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded,
                            size: 12,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF9E9EBF),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          slot["time"],
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isAvailable
                                ? const Color(0xFF2D2D4E)
                                : const Color(0xFFBBBBCC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= CTA =================
  Widget _buildCTA() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Résumé sélection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available_rounded,
                    color: Palette.gradientFirst, size: 18),
                const SizedBox(width: 8),
                Text(
                  "${_formatSelectedDay()} · $_selectedSlot",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D4E),
                  ),
                ),
              ],
            ),
          ),
          // Bouton
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (_selectedSlot == null || _selectedDay == null) {
                  AppToast.error(context, "Veuillez choisir une date et un créneau.");
                  return;
                }

                final selectedHour = int.parse(_selectedSlot!.split(":")[0]);
                final agencyCode = (widget.selectedAgency?['code'] ?? widget.existingAppointment?['agencyCode']);
                final serviceCode = (widget.selectedService?.code ?? widget.existingAppointment?['serviceCode']);
                final vehicleNumber = this.vehicleNumber;

                if (agencyCode == null || serviceCode == null ||
                    agencyCode.isEmpty || serviceCode.isEmpty || vehicleNumber.isEmpty) {
                  AppToast.error(context, "Données invalides ou incomplètes.");
                  return;
                }

                try {
                  bool success = false;

                  if (widget.mode == "reschedule") {
                    final apptNo = widget.existingAppointment!["appointmentNo"]
                        ?? widget.existingAppointment!["AppointmentNo"];

                    if (apptNo == null) {
                      AppToast.error(context, "Numéro de rendez-vous introuvable.");
                      return;
                    }

                    success = await AppointmentService.rescheduleAppointment(
                      appointmentNo: apptNo.toString(),
                      date: _selectedDay!,
                      startTime: selectedHour,
                      endTime: selectedHour + 1,
                    );
                  } else {
                    final apptNo = await AppointmentService.createAppointment(
                      agencyCode: agencyCode,
                      serviceCode: serviceCode,
                      vehicleNumber: vehicleNumber,
                      date: _selectedDay!,
                      startTime: selectedHour,
                      endTime: selectedHour + 1,
                      pontId: "AUTO",
                      customerNumber: _customerNumber ?? '',
                      serviceDescription: widget.selectedService?.description ?? '',
                    );
                    _lastCreatedAppointmentNo = apptNo;
                    success = apptNo != null;
                  }
                  var serv = widget.selectedService?.description;
                  print("servicccceeeeeee");
                  print(serv);
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmationScreen(
                          selectedVehicle: widget.selectedVehicle,
                          selectedAgency: widget.selectedAgency ?? {
                            'code': widget.existingAppointment?['agencyCode'] ?? '',
                            'name': widget.existingAppointment?['agencyName'] ?? '',
                          },
                          existingAppointment: widget.existingAppointment,
                          selectedService: widget.selectedService ?? ServiceModel(
                            code: widget.existingAppointment?['serviceCode'] ?? '',
                            name: widget.existingAppointment?['serviceCode'] ?? '',
                            icon: Icons.miscellaneous_services_rounded,
                          ),
                          selectedDate: _selectedDay!,
                          selectedSlot: _selectedSlot!,
                          appointmentNo: widget.mode == "reschedule"
                              ? widget.existingAppointment!["appointmentNo"].toString()
                              : _lastCreatedAppointmentNo ?? '',
                          customerEmail: _customerEmail ?? '',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  final raw = e.toString();

                  String msg = raw;
                  if (raw.contains('Exception:')) {
                    msg = raw.split('Exception:').last.trim();
                  }
                  if (raw.contains('Bad state:')) {
                    msg = raw.split('Bad state:').last.trim();
                  }

                  if (msg.length > 80) msg = '${msg.substring(0, 80)}...';

                  if (raw.contains('pont') || raw.contains('Aucun pont')) {
                    AppToast.show(context,
                      title: 'Aucun pont disponible',
                      message: 'Ce créneau est complet. Choisissez un autre horaire.',
                      type: ToastType.error,
                    );
                  } else if (raw.contains('SocketException') || raw.contains('connexion')) {
                    AppToast.show(context,
                      title: 'Erreur de connexion',
                      message: 'Vérifiez votre connexion réseau.',
                      type: ToastType.error,
                    );
                  } else {
                    AppToast.error(context, msg);
                  }
                }
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Palette.gradientFirst, Palette.gradientSecond],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.gradientFirst.withOpacity(0.4),
                      blurRadius: 16,
                      // offset: EdgeInsets.only(top: 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),

                      Text(
                        widget.mode == "reschedule"
                            ? "Modifier votre rendez-vous"
                            : "Choisir un créneau",
                        style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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