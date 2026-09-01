import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Service/appointment_share_service.dart';
import '../Service/appointment_service.dart';
import '../config/Palette.dart';
import '../models/service_model.dart';
import '../models/vehicle_model.dart';
import 'step_indicator.dart';

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

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  static const String _backendBaseUrl =
      'http://127.0.0.1:5032';

  String? _shareUrl;

  bool _isGeneratingShareLink = false;
  Future<String> _getShareUrl() async {
    // Si déjà généré, on le réutilise.
    if (_shareUrl != null &&
        _shareUrl!.isNotEmpty) {
      return _shareUrl!;
    }

    final agencyAddress =
        widget.selectedAgency['address']
            ?.toString() ??
            '';

    final agencyPhone =
        widget.selectedAgency['phoneNo']
            ?.toString() ??
            widget.selectedAgency['phone']
                ?.toString() ??
            '';

    final vehicleRegistration =
        widget.selectedVehicle
            ?.registrationNumber
            ?.toString() ??
            '';

    final vehicleName =
        widget.selectedVehicle
            ?.fullName
            ?.toString() ??
            '';

    final result =
    await AppointmentShareService
        .createShareLink(
      appointmentNo:
      widget.appointmentNo,

      customerEmail:
      widget.customerEmail,

      vehicleRegistration:
      vehicleRegistration,

      vehicleName:
      vehicleName,

      agencyName:
      widget.selectedAgency['name']
          ?.toString() ??
          '',

      agencyAddress:
      agencyAddress,

      agencyPhone:
      agencyPhone,

      serviceName:
      widget.selectedService.name,

      appointmentDate:
      widget.selectedDate,

      appointmentTime:
      widget.selectedSlot,
    );

    _shareUrl =
        result.shareUrl;

    return result.shareUrl;
  }
  String get _formattedDate {
    const days = [
      'Lun',
      'Mar',
      'Mer',
      'Jeu',
      'Ven',
      'Sam',
      'Dim',
    ];

    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    final date = widget.selectedDate;

    return '${days[date.weekday - 1]}. '
        '${date.day} '
        '${months[date.month - 1]}';
  }

  String get _daysUntil {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final appointmentDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    final difference =
        appointmentDate.difference(today).inDays;

    if (difference == 0) {
      return "Aujourd'hui";
    }

    if (difference < 0) {
      return 'Passé';
    }

    return 'J-$difference';
  }

  String get _vehicleRegistration {
    final registration =
        widget.selectedVehicle?.registrationNumber;

    if (registration != null &&
        registration.toString().trim().isNotEmpty) {
      return registration.toString();
    }

    final numVehicle =
        widget.selectedVehicle?.numVehicle;

    if (numVehicle != null &&
        numVehicle.toString().trim().isNotEmpty) {
      return numVehicle.toString();
    }

    final existingRegistration =
    widget.existingAppointment?['registrationNumber'];

    if (existingRegistration != null &&
        existingRegistration.toString().trim().isNotEmpty) {
      return existingRegistration.toString();
    }

    final existingVehicle =
    widget.existingAppointment?['numVehicle'];

    if (existingVehicle != null &&
        existingVehicle.toString().trim().isNotEmpty) {
      return existingVehicle.toString();
    }

    return 'N/D';
  }

  String get _vehicleName {
    final fullName = widget.selectedVehicle?.fullName;

    if (fullName != null &&
        fullName.toString().trim().isNotEmpty) {
      return fullName.toString();
    }

    return '';
  }

  String get _agencyName {
    final name = widget.selectedAgency['name'];

    if (name != null &&
        name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    final existing =
    widget.existingAppointment?['agencyName'];

    if (existing != null &&
        existing.toString().trim().isNotEmpty) {
      return existing.toString();
    }

    return 'N/D';
  }

  String get _serviceName {
    final name = widget.selectedService.name;

    if (name.trim().isNotEmpty) {
      return name;
    }

    final existing =
    widget.existingAppointment?['serviceDescription'];

    if (existing != null &&
        existing.toString().trim().isNotEmpty) {
      return existing.toString();
    }

    return 'N/D';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuccessCard(),

                  const SizedBox(height: 20),

                  _buildSectionLabel(
                    'Notifications envoyées',
                  ),

                  const SizedBox(height: 10),

                  _buildEmailNotification(),

                  const SizedBox(height: 20),

                  _buildSectionLabel(
                    'Récapitulatif',
                  ),

                  const SizedBox(height: 10),

                  _buildRecapCard(),

                  const SizedBox(height: 20),

                  _buildSectionLabel(
                    'Actions',
                  ),

                  const SizedBox(height: 10),

                  _buildActionsGrid(),
                ],
              ),
            ),
          ),

          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Palette.gradientFirst,
            Palette.gradientSecond,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius:
                    BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.15),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color:
                        Palette.secondPageIconColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Text(
                    'Confirmation',
                    style:
                    GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color:
                      Palette.secondPageTitleColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              StepIndicator(
                currentStep: 5,
                totalSteps: 5,
              ),

              const SizedBox(height: 8),

              const Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Véhicule',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Agence',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Créneau',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Confirmation',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONFIRMATION
  // ===========================================================================

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0DFFE),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Palette.gradientFirst,
                  Palette.gradientSecond,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Rendez-vous confirmé !',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF26215C),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Votre rendez-vous a été enregistré '
                'avec succès.\n'
                'Vous recevrez un rappel 24h avant.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF888780),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 15,
                  color: Color(0xFF534AB7),
                ),

                const SizedBox(width: 8),

                Text(
                  'N° RDV  ',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color:
                    const Color(0xFF534AB7),
                  ),
                ),

                Flexible(
                  child: Text(
                    widget.appointmentNo,
                    overflow:
                    TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      const Color(
                        0xFF26215C,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMAIL NOTIFICATION
  // ===========================================================================

  Widget _buildEmailNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC0DD97),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFC0DD97),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size: 17,
              color: Color(0xFF27500A),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Rappel par e-mail',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    const Color(
                      0xFF27500A,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Un e-mail de rappel sera envoyé '
                      '24h avant le rendez-vous à\n'
                      '${widget.customerEmail}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color:
                    const Color(
                      0xFF3B6D11,
                    ),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF3B6D11),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RECAP
  // ===========================================================================

  Widget _buildRecapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          _buildRecapRow(
            icon:
            Icons.directions_car_rounded,
            iconBackground:
            const Color(0xFFEEEDFE),
            iconColor:
            const Color(0xFF534AB7),
            label: 'Véhicule',
            value: _vehicleRegistration,
            badge: _vehicleName,
          ),

          _buildRecapRow(
            icon: Icons
                .store_mall_directory_rounded,
            iconBackground:
            const Color(0xFFE1F5EE),
            iconColor:
            const Color(0xFF0F6E56),
            label: 'Agence',
            value: _agencyName,
          ),

          _buildRecapRow(
            icon:
            Icons.handyman_rounded,
            iconBackground:
            const Color(0xFFEAF3DE),
            iconColor:
            const Color(0xFF3B6D11),
            label: 'Service',
            value: _serviceName,
          ),

          _buildRecapRow(
            icon:
            Icons.calendar_today_rounded,
            iconBackground:
            const Color(0xFFFAEEDA),
            iconColor:
            const Color(0xFF854F0B),
            label: 'Date & heure',
            value:
            '$_formattedDate · ${widget.selectedSlot}',
            badge: _daysUntil,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String label,
    required String value,
    String? badge,
    bool isLast = false,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color:
            Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color:
                    const Color(
                      0xFF888780,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    const Color(
                      0xFF2C2C2A,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (badge != null &&
              badge.trim().isNotEmpty)
            Container(
              constraints:
              const BoxConstraints(
                maxWidth: 120,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                const Color(0xFFEEEDFE),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(0xFF534AB7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  Widget _buildActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildActionButton(
          icon:
          Icons.calendar_month_rounded,
          label: 'Ajouter au\ncalendrier',
          background:
          const Color(0xFFEEEDFE),
          foreground:
          const Color(0xFF534AB7),
          onTap: _addToCalendar,
        ),

        _buildActionButton(
          icon: Icons.place_rounded,
          label:
          'Voir l\'agence\nsur la carte',
          background:
          const Color(0xFFE1F5EE),
          foreground:
          const Color(0xFF0F6E56),
          onTap: _openAgencyMap,
        ),

        _buildActionButton(
          icon: Icons.qr_code_rounded,
          label: 'Partager\nle RDV',
          background:
          const Color(0xFFEAF3DE),
          foreground:
          const Color(0xFF3B6D11),
          onTap: _shareRdv,
        ),

        _buildActionButton(
          icon: Icons.cancel_outlined,
          label: 'Annuler\nle RDV',
          background:
          const Color(0xFFFCEBEB),
          foreground:
          const Color(0xFFA32D2D),
          onTap: _confirmCancel,
          danger: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: background,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: foreground,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight:
                FontWeight.w500,
                color: danger
                    ? const Color(
                  0xFFA32D2D,
                )
                    : const Color(
                  0xFF2C2C2A,
                ),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // QR CODE
  // ===========================================================================
  void _showShareQrDialog(
      String shareUrl,
      ) {
    showDialog(
      context: context,
      builder: (
          dialogContext,
          ) {
        return Dialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  'Partager le rendez-vous',
                  style:
                  GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF26215C,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'Scannez ce QR code '
                      'pour télécharger le '
                      'récapitulatif PDF.',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts.dmSans(
                    fontSize: 12,
                    height: 1.5,
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    border:
                    Border.all(
                      color:
                      const Color(
                        0xFFEEEEF5,
                      ),
                    ),
                  ),
                  child:
                  QrImageView(
                    // IMPORTANT :
                    // Le backend fournit
                    // directement l'URL.
                    data:
                    shareUrl,

                    version:
                    QrVersions.auto,

                    size:
                    200,

                    backgroundColor:
                    Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal:
                    12,
                    vertical:
                    8,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFEEEDFE,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    'N° ${widget.appointmentNo}',
                    style:
                    GoogleFonts.dmSans(
                      fontSize:
                      12,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      const Color(
                        0xFF534AB7,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextButton(
                  onPressed:
                      () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text(
                    'Fermer',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _shareRdv() async {
    if (_isGeneratingShareLink) {
      return;
    }

    setState(() {
      _isGeneratingShareLink = true;
    });

    try {
      final shareUrl =
      await _getShareUrl();

      if (!mounted) {
        return;
      }

      _showShareQrDialog(
        shareUrl,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de générer '
                'le QR code : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingShareLink =
          false;
        });
      }
    }
  }
  // ===========================================================================
  // ANNULATION
  // ===========================================================================

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),
          title: Text(
            'Annuler le RDV ?',
            style: GoogleFonts.dmSans(
              fontWeight:
              FontWeight.w700,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir '
                'annuler votre rendez-vous '
                'du $_formattedDate à '
                '${widget.selectedSlot} ?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color:
              Colors.grey.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                'Non, garder',
                style: TextStyle(
                  color:
                  Palette.gradientFirst,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _cancelAppointment();
              },
              child: const Text(
                'Annuler le RDV',
                style: TextStyle(
                  color:
                  Color(0xFFA32D2D),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAppointment() async {
    try {
      await AppointmentService
          .cancelAppointment(
        widget.appointmentNo,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'RDV annulé avec succès',
          ),
        ),
      );

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : $e',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // ACTIONS TEMPORAIRES
  // ===========================================================================

  void _addToCalendar() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Ajout au calendrier prochainement',
        ),
      ),
    );
  }

  void _openAgencyMap() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Agence : $_agencyName',
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM BUTTONS
  // ===========================================================================

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
            Colors.grey.shade100,
          ),
        ),
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Palette.gradientFirst,
                    Palette.gradientSecond,
                  ],
                ),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: _goHome,
                icon: const Icon(
                  Icons.home_rounded,
                  size: 18,
                ),
                label: Text(
                  'Retour à l\'accueil',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.transparent,
                  foregroundColor:
                  Colors.white,
                  shadowColor:
                  Colors.transparent,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
              _goToAppointments,
              icon: const Icon(
                Icons.history_rounded,
                size: 16,
              ),
              label: Text(
                'Voir mes rendez-vous',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Palette.gradientFirst,
                side: BorderSide(
                  color:
                  Palette.gradientFirst
                      .withOpacity(0.4),
                ),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  void _goToAppointments() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionLabel(
      String text,
      ) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight:
        FontWeight.w600,
        color:
        const Color(0xFF888780),
        letterSpacing: 0.6,
      ),
    );
  }
}