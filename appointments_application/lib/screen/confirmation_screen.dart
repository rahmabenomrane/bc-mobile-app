
import 'dart:math';
import 'package:appointments_application/screen/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Service/appointment_service.dart';
import '../config/Palette.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';

class ConfirmationScreen extends StatefulWidget {
  final Vehicle? selectedVehicle;
  final Map<String, dynamic> selectedAgency;
  final ServiceModel selectedService;
  final DateTime selectedDate;
  final String selectedSlot;
  final String appointmentNo;
  final String customerEmail;

  final Map<String, dynamic>? existingAppointment;

  const ConfirmationScreen({
    super.key,
    required this.selectedVehicle,
    required this.selectedAgency,
    required this.selectedService,
    required this.selectedDate,
    required this.selectedSlot,
    required this.appointmentNo,
    required this.customerEmail,
    this.existingAppointment,
  });



  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {

  // ── Animations ──────────────────────────────────────────────────────────────
  late AnimationController _heroCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _notifCtrl;
  late Animation<double> _heroScale;
  late Animation<double> _heroOpacity;
  late List<_ConfettiParticle> _particles;

  // Numéro de RDV simulé
  final String _rdvNumber =
      'RDV-2026-${(4000 + Random().nextInt(999)).toString()}';

  @override
  void initState() {
    super.initState();

    // Hero pop-in
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroScale = CurvedAnimation(
      parent: _heroCtrl,
      curve: Curves.easeOutBack,
    );
    _heroOpacity = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeIn);
    // Confettis
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _particles = List.generate(50, (_) => _ConfettiParticle());


    _notifCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Lancer les animations en séquence
    _heroCtrl.forward().then((_) {
      _confettiCtrl.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _notifCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _confettiCtrl.dispose();
    _notifCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _formattedDate {
    const days   = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    final d = widget.selectedDate;
    return '${days[d.weekday - 1]}. ${d.day} ${months[d.month - 1]}';
  }

  String get _daysUntil {
    final diff = widget.selectedDate
        .difference(DateTime.now())
        .inDays;
    return diff <= 0 ? 'Aujourd\'hui' : 'J-$diff';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuccessHero(),
                  const SizedBox(height: 16),
                  _sectionLabel('Notifications envoyées'),
                  const SizedBox(height: 10),
                  _buildNotifBanner(
                    delay: 0.0,
                    icon: Icons.mail_outline_rounded,
                    iconBg: const Color(0xFFC0DD97),
                    iconColor: const Color(0xFF27500A),
                    bg: const Color(0xFFEAF3DE),
                    border: const Color(0xFFC0DD97),
                    title: 'Confirmation par e-mail',
                    body: 'Un e-mail récapitulatif a été envoyé à\n${widget.customerEmail}',
                    titleColor: const Color(0xFF27500A),
                    bodyColor: const Color(0xFF3B6D11),
                    checkColor: const Color(0xFF3B6D11),
                  ),
                  // const SizedBox(height: 8),
                  // _buildNotifBanner(
                  //   delay: 0.3,
                  //   icon: Icons.sms_outlined,
                  //   iconBg: const Color(0xFF9FE1CB),
                  //   iconColor: const Color(0xFF085041),
                  //   bg: const Color(0xFFE1F5EE),
                  //   border: const Color(0xFF9FE1CB),
                  //   title: 'SMS de confirmation',
                  //   body: 'Un SMS a été envoyé au\n+216 XX XXX XXX',
                  //   titleColor: const Color(0xFF085041),
                  //   bodyColor: const Color(0xFF0F6E56),
                  //   checkColor: const Color(0xFF0F6E56),
                  // ),
                  // const SizedBox(height: 8),
                  // _buildNotifBanner(
                  //   delay: 0.6,
                  //   icon: Icons.notifications_none_rounded,
                  //   iconBg: const Color(0xFFAFA9EC),
                  //   iconColor: const Color(0xFF26215C),
                  //   bg: const Color(0xFFEEEDFE),
                  //   border: const Color(0xFFAFA9EC),
                  //   title: 'Rappel automatique activé',
                  //   body: 'Vous serez notifié 24h avant votre rendez-vous.',
                  //   titleColor: const Color(0xFF26215C),
                  //   bodyColor: const Color(0xFF534AB7),
                  //   checkColor: const Color(0xFF534AB7),
                  // ),
                  const SizedBox(height: 20),
                  _sectionLabel('Récapitulatif'),
                  const SizedBox(height: 10),
                  _buildRecapCard(),
                  const SizedBox(height: 20),
                  _sectionLabel('Actions'),
                  const SizedBox(height: 10),
                  _buildActionsGrid(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildBottomCTA(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Palette.gradientFirst, Palette.gradientSecond],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Palette.secondPageIconColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirmation',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Palette.secondPageTitleColor,
                          )),

                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StepIndicator(currentStep: 5, totalSteps: 5),
              const SizedBox(height: 6),

              // Labels étapes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepLabel('Véhicule',     done: false, active: false),
                  _StepLabel('Agence',       done: false, active: false),
                  _StepLabel('Service',      done: false, active: false),
                  _StepLabel('Créneau',      done: false, active: false),
                  _StepLabel('Confirmation', done: false, active: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success Hero ─────────────────────────────────────────────────────────────

  Widget _buildSuccessHero() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0DFFE)),
        boxShadow: [
          BoxShadow(
            color: Palette.gradientFirst.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Confettis
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(
                    _particles, _confettiCtrl.value),
                child: const SizedBox(height: 180, width: double.infinity),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _heroScale,
                    child: FadeTransition(
                      opacity: _heroOpacity,
                      child: Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEDFE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Palette.gradientFirst,
                                  Palette.gradientSecond],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Rendez-vous confirmé !',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF26215C),
                      )),
                  const SizedBox(height: 6),
                  Text(
                    'Votre rendez-vous a été enregistré avec succès.\nVous recevrez un rappel 24h avant.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF888780),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Badge numéro RDV
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            size: 14, color: Color(0xFF534AB7)),
                        const SizedBox(width: 8),
                        Text('N° RDV ',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF534AB7),
                            )),
                        Text(_rdvNumber,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF26215C),
                              letterSpacing: 0.4,
                            )),
                      ],
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

  // ── Notif Banner ─────────────────────────────────────────────────────────────

  Widget _buildNotifBanner({
    required double delay,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color bg,
    required Color border,
    required String title,
    required String body,
    required Color titleColor,
    required Color bodyColor,
    required Color checkColor,
  }) {
    final start = delay / 1.0;
    final end   = (delay + 0.4).clamp(0.0, 1.0);

    final slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notifCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _notifCtrl,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        )),
                    const SizedBox(height: 2),
                    Text(body,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: bodyColor,
                          height: 1.5,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded,
                  size: 18, color: checkColor),
            ],
          ),
        ),
      ),
    );
  }

  // ── Recap Card ───────────────────────────────────────────────────────────────

  Widget _buildRecapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _recapRow(
            iconBg: const Color(0xFFEEEDFE),
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF534AB7),
            label: 'Véhicule',
            value: widget.selectedVehicle?.registrationNumber ??
                widget.selectedVehicle?.numVehicle ??
                widget.existingAppointment?['registrationNumber']?.toString() ??
                widget.existingAppointment?['numVehicle']?.toString() ??
                'N/D',
            badgeBg: const Color(0xFFEEEDFE),
            badgeFg: const Color(0xFF3C3489),
            badge: widget.selectedVehicle?.fullName ?? '',
            isLast: false,
          ),
          _recapRow(
            iconBg: const Color(0xFFE1F5EE),
            icon: Icons.store_mall_directory_rounded,
            iconColor: const Color(0xFF0F6E56),
            label: 'Agence',
            value: widget.selectedAgency['name'],
            isLast: false,
          ),
          _recapRow(
            iconBg: const Color(0xFFEAF3DE),
            icon: Icons.handyman_rounded,
            iconColor: const Color(0xFF3B6D11),
            label: 'Service ',
            value: '${widget.selectedService.name} · ',
            badgeBg: const Color(0xFFEAF3DE),
            badgeFg: const Color(0xFF27500A),

            isLast: false,
          ),
          _recapRow(
            iconBg: const Color(0xFFFAEEDA),
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF854F0B),
            label: 'Date & heure',
            value: '$_formattedDate · ${widget.selectedSlot}',
            badgeBg: const Color(0xFFFAEEDA),
            badgeFg: const Color(0xFF633806),
            badge: _daysUntil,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _recapRow({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? badgeBg,
    Color? badgeFg,
    String? badge,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                      fontSize: 11, color: const Color(0xFF888780),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2A),
                    )),
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  )),
            ),
          ],
        ],
      ),
    );
  }

  // ── Actions Grid ─────────────────────────────────────────────────────────────

  Widget _buildActionsGrid() {
    final actions = [
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'Ajouter au\ncalendrier',
        'bg': const Color(0xFFEEEDFE),
        'fg': const Color(0xFF534AB7),
        'danger': false,
      },
      {
        'icon': Icons.place_rounded,
        'label': 'Voir l\'agence\nsur la carte',
        'bg': const Color(0xFFE1F5EE),
        'fg': const Color(0xFF0F6E56),
        'danger': false,
      },
      {
        'icon': Icons.share_rounded,
        'label': 'Partager\nle RDV',
        'bg': const Color(0xFFEAF3DE),
        'fg': const Color(0xFF3B6D11),
        'danger': false,
      },
      {
        'icon': Icons.cancel_outlined,
        'label': 'Annuler\nle RDV',
        'bg': const Color(0xFFFCEBEB),
        'fg': const Color(0xFFA32D2D),
        'danger': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () {
            if (a['danger'] == true) {
              _confirmCancel();
            } else if (a['label'] == 'Partager\nle RDV') {
              _shareRdv();
            }
            },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: a['bg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a['icon'] as IconData,
                      size: 18, color: a['fg'] as Color),
                ),
                const SizedBox(height: 6),
                Text(a['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: a['danger'] == true
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFF2C2C2A),
                      height: 1.3,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Confirm cancel dialog ────────────────────────────────────────────────────

  // ✅ Annuler RDV
  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Annuler le RDV ?',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Êtes-vous sûr de vouloir annuler votre rendez-vous du $_formattedDate à ${widget.selectedSlot} ?',
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non, garder',
                style: TextStyle(color: Palette.gradientFirst)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AppointmentService.cancelAppointment(widget.appointmentNo);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("RDV annulé avec succès")),
                  );
                  Navigator.popUntil(context, (r) => r.isFirst);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur: $e")),
                );
              }
            },
            child: const Text('Annuler le RDV',
                style: TextStyle(color: Color(0xFFA32D2D))),
          ),
        ],
      ),
    );
  }

//  Partager avec QR code
  void _shareRdv() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Partager le RDV',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF26215C),
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEF5)),
                ),
                child: QrImageView(
                  data: widget.appointmentNo,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 12),
              // Text(
              //   widget.appointmentNo,
              //   style: GoogleFonts.dmSans(
              //     fontSize: 13,
              //     fontWeight: FontWeight.w600,
              //     color: const Color(0xFF534AB7),
              //   ),
              // ),
              const SizedBox(height: 8),
              // Text(
              //   '$_formattedDate · ${widget.selectedSlot}',
              //   style: GoogleFonts.dmSans(
              //     fontSize: 12,
              //     color: Colors.grey.shade500,
              //   ),
              // ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer',
                    style: TextStyle(color: Palette.gradientFirst)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── Bottom CTA ───────────────────────────────────────────────────────────────

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Palette.gradientFirst.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton principal
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.gradientFirst, Palette.gradientSecond],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Palette.gradientFirst.withOpacity(0.3),
                    blurRadius: 14, offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                icon: const Icon(Icons.home_rounded, size: 18),
                label: Text('Retour à l\'accueil',
                    style: GoogleFonts.dmSans(
                      fontSize: 15, fontWeight: FontWeight.w600,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bouton secondaire
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: naviguer vers l'écran mes rendez-vous
              },
              icon: const Icon(Icons.history_rounded, size: 16),
              label: Text('Voir mes rendez-vous',
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w500,
                  )),
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.gradientFirst,
                side: BorderSide(
                    color: Palette.gradientFirst.withOpacity(0.4),
                    width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF888780),
      letterSpacing: 0.6,
    ),
  );
}

// ─── Confetti ──────────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double radius;
  final Color color;
  final bool isRect;
  final double angle;
  final double angleSpeed;

  _ConfettiParticle()
      : x = Random().nextDouble(),
        startY = -Random().nextDouble() * 0.4,
        speed = 0.2 + Random().nextDouble() * 0.4,
        radius = 2 + Random().nextDouble() * 4,
        color = [
          const Color(0xFF534AB7),
          const Color(0xFFAFA9EC),
          const Color(0xFF1D9E75),
          const Color(0xFF5DCAA5),
          const Color(0xFFEF9F27),
          const Color(0xFFEEEDFE),
          const Color(0xFF97C459),
        ][Random().nextInt(7)],
        isRect = Random().nextBool(),
        angle = Random().nextDouble() * pi * 2,
        angleSpeed = (Random().nextDouble() - 0.5) * 0.15;
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.startY + progress * p.speed) % 1.2;
      if (y < 0) continue;
      final paint = Paint()..color = p.color.withOpacity(
          (1 - progress * 0.6).clamp(0.0, 1.0));
      final px = p.x * size.width;
      final py = y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.angle + progress * p.angleSpeed * 20);
      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero,
              width: p.radius * 2, height: p.radius),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.radius, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ─── Micro-widget step label ───────────────────────────────────────────────────

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