import 'package:appointments_application/config/Palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Service/appointment_service.dart';
import 'appointment_slot_screen.dart';

class RdvsList extends StatefulWidget {
  final Function(int)? onNavigate;
  final String customerNumber;
  final bool showHistory;


  const RdvsList({
    super.key,
    required this.customerNumber,
    this.onNavigate,
    this.showHistory = false,
  });

  @override
  State<RdvsList> createState() => RdvsListState();
}

class RdvsListState extends State<RdvsList> {
  List<dynamic> rdvs = [];
  bool loading = true;
  final AppointmentService appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "confirmé":   return const Color(0xFF2ECC71);
      case "en attente": return const Color(0xFFF39C12);
      case "terminé":    return Colors.grey.shade500;
      default:           return Palette.gradientFirst;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case "confirmé":   return const Color(0xFF2ECC71).withOpacity(0.12);
      case "en attente": return const Color(0xFFF39C12).withOpacity(0.12);
      case "terminé":    return Colors.grey.shade100;
      default:           return Palette.gradientFirst.withOpacity(0.1);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "confirmé":   return Icons.check_circle_rounded;
      case "en attente": return Icons.schedule_rounded;
      case "terminé":    return Icons.history_rounded;
      default:           return Icons.info_rounded;
    }
  }

  void _rescheduleAppointment(dynamic rdv) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reporter le rendez-vous",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Souhaitez-vous choisir un nouveau créneau pour ce rendez-vous ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context, true);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentSlotScreen(
                    mode: "reschedule",
                    existingAppointment: rdv,
                  ),
                ),
              );
              if (result == true) await loadAppointments();
            },
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: const Text("Reporter"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _cancelAppointment(dynamic rdv) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Annuler le rendez-vous",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Êtes-vous sûr de vouloir annuler ce rendez-vous ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Retour",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text("Annuler le RDV"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AppointmentService.cancelAppointment(
        rdv["appointmentNo"],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rendez-vous annulé avec succès"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Recharge directement la liste
      await loadAppointments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'annulation : $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredRdvs = rdvs.where((rdv) {
      final endTime = DateTime.tryParse(rdv["endTime"] ?? "");
      if (endTime == null) return false;
      return widget.showHistory
          ? endTime.isBefore(now)
          : endTime.isAfter(now);
    }).toList();

    final next = filteredRdvs.isNotEmpty ? filteredRdvs.first : null;

    return Scaffold(
      body: SizedBox.expand(   // ← FIX overflow: contraint le Stack à la taille de l'écran
        child: Stack(
          children: [
            // ── Gradient Background ──────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              height: MediaQuery.of(context).size.height * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Palette.gradientFirst, Palette.gradientSecond],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(0);
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: Palette.secondPageIconColor),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.help_outline_rounded,
                              size: 18, color: Palette.secondPageIconColor),
                        ),
                      ],
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.showHistory
                              ? "HISTORIQUE"
                              : "PROCHAIN RENDEZ-VOUS",
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: Palette.secondPageIconColor.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          next != null
                              ? next["agencyName"]
                              : "Aucun rendez-vous",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Palette.secondPageTitleColor,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (next != null)
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.calendar_today_rounded,
                                label: next["startTime"]
                                    .toString()
                                    .substring(0, 10),
                              ),
                              _InfoChip(
                                icon: Icons.access_time_rounded,
                                label: next["startTime"]
                                    .toString()
                                    .split("T")[1]
                                    .substring(0, 5),
                              ),
                              _InfoChip(
                                icon: Icons.build_circle_outlined,
                                label: next["serviceDescription"] ?? "",
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── White Sheet ──────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Handle bar
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // Title row
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Text(
                                  "Vos rendez-vous",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.circuitsColor,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Palette.gradientFirst
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${filteredRdvs.length} RDV",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Palette.gradientFirst,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Cards list
                          Expanded(
                            child: loading
                                ? Center(
                              child: CircularProgressIndicator(
                                  color: Palette.gradientFirst),
                            )
                                : filteredRdvs.isEmpty
                                ? _EmptyState(
                                showHistory: widget.showHistory)
                                : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 4, 20, 40),
                              itemCount: filteredRdvs.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _RdvCard(
                                  rdv: filteredRdvs[index],
                                  showHistory: widget.showHistory,
                                  statusColor: _statusColor,
                                  statusBgColor: _statusBgColor,
                                  statusIcon: _statusIcon,
                                  onReschedule:
                                  _rescheduleAppointment,
                                  onCancel: _cancelAppointment,

                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadAppointments() async {
    try {
      final data = await appointmentService
          .getCustomerAppointments(widget.customerNumber);
      setState(() {
        rdvs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Chip d'info dans le header — utilise Palette directement (pas de paramètre dynamic)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Palette.secondPageContainerGradient1stColor,
            Palette.secondPageContainerGradient2ndColor,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Palette.secondPageIconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Palette.secondPageIconColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte RDV — utilise Palette directement (pas de paramètre dynamic)
class _RdvCard extends StatelessWidget {
  final dynamic rdv;
  final bool showHistory;
  final Color Function(String) statusColor;
  final Color Function(String) statusBgColor;
  final IconData Function(String) statusIcon;
  final void Function(dynamic) onReschedule;
  final void Function(dynamic) onCancel;

  const _RdvCard({
    required this.rdv,
    required this.showHistory,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = rdv["status"] ?? "";
    final startTime = rdv["startTime"].toString();
    final date = startTime.split("T")[0];
    final time = startTime.split("T")[1].substring(0, 5);

    final normalizedStatus = status.toLowerCase();

    final bool isCancelled = normalizedStatus == "cancelled";

    final bool canModify =
        !showHistory &&
            !isCancelled;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        Palette.gradientFirst.withOpacity(0.85),
                        Palette.gradientSecond,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: const Icon(Icons.build_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rdv["serviceDescription"] ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Palette.circuitsColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rdv["agencyName"] ?? "",
                        style: TextStyle(
                            fontSize: 13, color: Palette.setsColor),
                      ),
                    ],
                  ),
                ),
                if (!showHistory)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBgColor(status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon(status),
                            size: 13, color: statusColor(status)),
                        const SizedBox(width: 4),
                        Text(
                          _translateStatus(status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // Detail row
            Row(
              children: [
                _DetailPill(
                    icon: Icons.calendar_today_rounded,
                    label: date,
                    color: Palette.loopColor),
                const SizedBox(width: 8),
                _DetailPill(
                    icon: Icons.access_time_rounded,
                    label: time,
                    color: Palette.loopColor),
                const SizedBox(width: 8),
                _DetailPill(
                    icon: Icons.speed_rounded,
                    label: "${rdv["mileage"]} km",
                    color: Palette.loopColor),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car_rounded,
                          size: 14, color: Palette.setsColor),
                      const SizedBox(width: 5),
                      Text(
                        rdv["registrationNumber"] ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Palette.circuitsColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!showHistory)
                  if (canModify)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onCancel(rdv),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            "Annuler",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton.icon(
                          onPressed: () => onReschedule(rdv),
                          icon: const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            "Reporter",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ), ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
String _translateStatus(String status) {
  switch (status.toLowerCase()) {
    case "pending":
      return "En attente";

    case "confirmed":
      return "Confirmé";

    case "cancelled":
      return "Annulé";

    default:
      return status;
  }
}
class _EmptyState extends StatelessWidget {
  final bool showHistory;
  const _EmptyState({required this.showHistory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showHistory
                ? Icons.history_rounded
                : Icons.calendar_today_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            showHistory
                ? "Aucun historique disponible"
                : "Aucun rendez-vous à venir",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            showHistory
                ? "Vos anciens RDV apparaîtront ici"
                : "Prenez un rendez-vous pour commencer",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}