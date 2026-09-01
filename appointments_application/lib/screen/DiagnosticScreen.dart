import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Service/DiagnosticService.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  static const Color _primaryColor = Color(0xFF1565C0);
  static const Color _backgroundColor = Color(0xFFF4F6F9);

  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final DiagnosticService _diagnosticService =
  DiagnosticService('http://127.0.0.1:5032');

  File? _photo;
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _descController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
      );

      if (picked == null || !mounted) return;

      setState(() {
        _photo = File(picked.path);
        _result = null;
      });
    } catch (_) {
      _showError('Impossible d’ouvrir la caméra.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );

      if (picked == null || !mounted) return;

      setState(() {
        _photo = File(picked.path);
        _result = null;
      });
    } catch (_) {
      _showError('Impossible de sélectionner la photo.');
    }
  }

  Future<void> _analyze() async {
    final String description = _descController.text.trim();

    if (_photo == null && description.isEmpty) {
      _showError(
        'Ajoutez une photo ou décrivez le problème de votre véhicule.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final Map<String, dynamic> result =
      await _diagnosticService.sendDiagnostic(
        photo: _photo,
        description: description,
        agenceId: 1,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
      });

      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      debugPrint('Erreur diagnostic : $error');
      _showError(
        'Le diagnostic n’a pas pu être effectué. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  void _resetDiagnostic() {
    setState(() {
      _photo = null;
      _result = null;
      _descController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 12,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy_outlined,
                color: _primaryColor,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant automobile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pré-diagnostic intelligent',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _resetDiagnostic,
            tooltip: 'Nouvelle analyse',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                children: [
                  _buildAssistantWelcomeBubble(),
                  if (_photo != null ||
                      _descController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildUserMessage(),
                  ],
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    _buildLoadingBubble(),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    _buildResultBubble(_result!),
                  ],
                ],
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantWelcomeBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: _primaryColor,
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _whiteCardDecoration(
                const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const Text(
                'Bonjour ! Décrivez le problème de votre véhicule et ajoutez '
                    'une photo si possible. Je vais identifier le service adapté .',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage() {
    final String description = _descController.text.trim();

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: _primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_photo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _photo!,
                  width: 270,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              if (description.isNotEmpty) const SizedBox(height: 10),
            ],
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            if (description.isEmpty && _photo != null)
              const Text(
                'Analysez cette photo, s’il vous plaît.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: _primaryColor,
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: _whiteCardDecoration(
              BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Analyse en cours...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBubble(Map<String, dynamic> result) {
    final bool imageValide = result['imageValide'] != false;
    final bool vehiculeDetecte = result['vehiculeDetecte'] != false;

    if (!imageValide || !vehiculeDetecte) {
      return _buildInvalidResultCard(result);
    }


    final String service = _readString(
    result,
    const [
    'serviceLibelleDetecte',
    'serviceTypeDetecte',
    'typeServiceDetecte',
    'serviceType',
    ],
    fallback: 'Non déterminé',
    );

    final String urgence = _readString(
      result,
      const ['urgence'],
      fallback: 'Non précisée',
    );

    final String observation = _readString(
      result,
      const ['observationVisible', 'observation'],
    );

    final String zone = _readString(
      result,
      const ['zoneConcernee'],
    );

    final String conseil = _readString(
      result,
      const ['conseil'],
    );


    final bool diagnosticCertain = result['diagnosticCertain'] == true;
    final bool besoinInformations =
        result['besoinInformationsSupplementaires'] == true;

    final List<String> questions = _readStringList(
      result['questionsSupplementaires'],
    );

    // final List<Map<String, dynamic>> agencies = _readMapList(
    //   result['agencesRecommandees'],
    // );

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: _primaryColor,
            child: Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _whiteCardDecoration(
                const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiagnosticHeader(
                    service: service,
                    urgence: urgence,
                  ),

                  if (observation.isNotEmpty) ...[
                    const Divider(height: 30),
                    _buildTextSection(
                      title: 'Observation visible',
                      text: observation,
                      icon: Icons.visibility_outlined,
                    ),
                  ],
                  if (zone.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildTextSection(
                      title: 'Zone concernée',
                      text: zone,
                      icon: Icons.location_searching,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildDiagnosticStatus(
                    diagnosticCertain: diagnosticCertain,
                    besoinInformations: besoinInformations,
                  ),
                  if (conseil.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAdviceCard(conseil),
                  ],
                  // if (questions.isNotEmpty) ...[
                  //   const SizedBox(height: 18),
                  //   _buildQuestionsCard(questions),
                  // ],
                  // if (agencies.isNotEmpty) ...[
                  //   const Divider(height: 34),
                  //   _buildRecommendedAgencies(agencies, service),
                  // ],
                  const SizedBox(height: 16),
                  Text(
                    'Ce résultat est un pré-diagnostic indicatif et ne '
                        'remplace pas le contrôle d’un professionnel.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidResultCard(Map<String, dynamic> result) {
    final String message = _readString(
      result,
      const ['message', 'conseil', 'observationVisible'],
      fallback:
      'La photo ne permet pas d’identifier clairement un élément automobile.',
    );

    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticHeader({
    required String service,
    required String urgence,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.verified_outlined,
              color: _primaryColor,
              size: 22,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Résultat du pré-diagnostic',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildResultLine(
          icon: Icons.build_circle_outlined,
          title: 'Type de service recommandé',
          value: service,
        ),
        const SizedBox(height: 14),
        _buildResultLine(
          icon: Icons.warning_amber_rounded,
          title: 'Niveau d’urgence',
          value: urgence,
          valueColor: _getUrgencyColor(urgence),
        ),
      ],
    );
  }

  Widget _buildDiagnosticStatus({
    required bool diagnosticCertain,
    required bool besoinInformations,
  }) {
    final String title =
    diagnosticCertain ? 'Diagnostic probable' : 'Pré-diagnostic à confirmer';

    final String subtitle = besoinInformations
        ? 'Des informations supplémentaires peuvent améliorer l’évaluation.'
        : 'Les éléments visibles sont suffisants pour orienter le service.';

    final IconData icon =
    diagnosticCertain ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String conseil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFE5FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: _primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conseil',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  conseil,
                  style: const TextStyle(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuestionsCard(List<String> questions) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFFFF8E8),
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: const Color(0xFFFFE2A8)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // const Row(
  //         //   children: [
  //         //     Icon(
  //         //       Icons.help_outline,
  //         //       color: Color(0xFF9A6700),
  //         //     ),
  //         //     SizedBox(width: 9),
  //         //     // Expanded(
  //         //     //   child: Text(
  //         //     //     'Pour affiner le diagnostic',
  //         //     //     style: TextStyle(
  //         //     //       color: Color(0xFF805500),
  //         //     //       fontWeight: FontWeight.bold,
  //         //     //     ),
  //         //     //   ),
  //         //     // ),
  //         //   ],
  //         // ),
  //         // const SizedBox(height: 10),
  //         // ...questions.map(
  //         //       (question) => Padding(
  //         //     padding: const EdgeInsets.only(bottom: 9),
  //         //     child: Row(
  //         //       crossAxisAlignment: CrossAxisAlignment.start,
  //         //       children: [
  //         //         const Padding(
  //         //           padding: EdgeInsets.only(top: 7),
  //         //           child: Icon(
  //         //             Icons.circle,
  //         //             size: 6,
  //         //             color: Color(0xFF9A6700),
  //         //           ),
  //         //         ),
  //         //         const SizedBox(width: 9),
  //         //         Expanded(
  //         //           child: Text(
  //         //             question,
  //         //             style: const TextStyle(height: 1.4),
  //         //           ),
  //         //         ),
  //         //       ],
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecommendedAgencies(
      List<Map<String, dynamic>> agencies,
      String serviceType,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_city_outlined,
              color: _primaryColor,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                agencies.length == 1
                    ? 'Agence recommandée'
                    : '${agencies.length} agences recommandées',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Ces agences proposent au moins un service de type '
              '« $serviceType ».',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ...agencies.map(_buildAgencyCard),
      ],
    );
  }

  Widget _buildAgencyCard(Map<String, dynamic> agency) {
    final String agencyCode = _readString(
      agency,
      const ['agencyCode', 'code'],
    );

    final String agencyName = _readString(
      agency,
      const ['agencyName', 'name'],
      fallback: agencyCode.isNotEmpty ? agencyCode : 'Agence STA',
    );

    final String address = _readString(
      agency,
      const ['address'],
    );

    final String serviceCode = _readString(
      agency,
      const ['serviceCode'],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE7F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.car_repair_outlined,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agencyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (agencyCode.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  // Text(
                  //   'Code agence : $agencyCode',
                  //   style: TextStyle(
                  //     color: Colors.grey.shade600,
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ],
                if (serviceCode.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Service  disponible',
                      // $serviceCode
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              '$label : $value',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultLine({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: _primaryColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection({
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Color _getUrgencyColor(String urgence) {
    final String value = urgence.toLowerCase();

    if (value.contains('élev') ||
        value.contains('eleve') ||
        value.contains('critique') ||
        value.contains('urgent')) {
      return Colors.red.shade700;
    }

    if (value.contains('moyen') || value.contains('modér')) {
      return Colors.orange.shade800;
    }

    return Colors.green.shade700;
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_photo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _photo!,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Photo ajoutée',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading
                        ? null
                        : () {
                      setState(() {
                        _photo = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: _primaryColor,
                  size: 28,
                ),
                onSelected: (value) {
                  if (value == 'camera') {
                    _pickImage();
                  } else {
                    _pickFromGallery();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Text('Prendre une photo'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library_outlined),
                        SizedBox(width: 10),
                        Text('Choisir une image'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _descController,
                  enabled: !_loading,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Décrivez le problème...',
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _primaryColor,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: _loading ? null : _analyze,
                  icon: _loading
                      ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _whiteCardDecoration(BorderRadius borderRadius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _readString(
      Map<String, dynamic> source,
      List<String> keys, {
        String fallback = '',
      }) {
    for (final String key in keys) {
      final dynamic value = source[key];
      if (value == null) continue;

      final String text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  List<String> _readStringList(dynamic value) {
    if (value is! List) return <String>[];

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
      ),
    )
        .toList();
  }
}
