import 'package:flutter/material.dart';
import '../Service/claim_service.dart';
import '../models/claim_model.dart';
import 'AppFooter.dart';
import 'create_claim_screen.dart';

class ClaimsListScreen extends StatefulWidget {
  const ClaimsListScreen({super.key, this.onNavigate});
  final Function(int)? onNavigate;

  @override
  State<ClaimsListScreen> createState() => _ClaimsListScreenState();
}

class _ClaimsListScreenState extends State<ClaimsListScreen> with WidgetsBindingObserver {
  List<ClaimModel> _claims = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadClaims();
  }
  bool _firstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_firstLoad) {
      _firstLoad = false;
      loadClaims();
    }
  }
  Future<void> loadClaims() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final claims = await ClaimService.fetchClaims();
      setState(() => _claims = claims);
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Session expirée')) {
        _showSessionExpiredDialog();
      } else {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Mes réclamations',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed:loadClaims,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreate,
        backgroundColor: const Color(0xFFA32D2D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      bottomNavigationBar: SizedBox(
        height: 95,
        child: AppFooter(
          currentIndex: 0,
          onTap: (i) {
            widget.onNavigate?.call(i);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: loadClaims,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ]),
        ),
      );
    }

    if (_claims.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFCEBEB),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.report_problem_rounded,
                size: 44, color: Color(0xFFA32D2D)),
          ),
          const SizedBox(height: 18),
          const Text('Aucune réclamation',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Vous n\'avez pas encore soumis de réclamation.',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _goToCreate,
            icon: const Icon(Icons.add),
            label: const Text('Créer une réclamation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA32D2D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: loadClaims,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _claims.length,
        itemBuilder: (context, i) => ClaimCard(claim: _claims[i]), // Changé ici
      ),
    );
  }

  Future<void> _goToCreate() async {
    final created = await Navigator.push<ClaimModel>(
      context,
      MaterialPageRoute(builder: (_) => const CreateClaimScreen()),
    );
    if (created != null) {
      await loadClaims();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réclamation #${created.claimNumber} soumise avec succès'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Card réclamation
class ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  const ClaimCard({required this.claim});

  static const _statusColor = {
    0: Color(0xFF1565C0),  // En attente
    1: Color(0xFF2E7D32),  // En cours
    2: Color(0xFF546E7A),  // Résolue
    3: Color(0xFFA32D2D),  // Rejetée
  };
  static const _statusBg = {
    0: Color(0xFFE3F2FD),
    1: Color(0xFFE8F5E9),
    2: Color(0xFFECEFF1),
    3: Color(0xFFFCEBEB),
  };
  static const _priorityColor = {
    0: Color(0xFF388E3C),  // Faible
    1: Color(0xFFF57F17),  // Moyen
    2: Color(0xFFC62828),  // Élevé
  };

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor[claim.status] ?? Colors.grey;
    final sBg = _statusBg[claim.status] ?? Colors.grey.shade100;
    final pColor = _priorityColor[claim.priority] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête : Numéro de réclamation + Statut
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${claim.claimNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFFA32D2D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    claim.statusLabel,
                    style: TextStyle(
                      color: sColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. DESCRIPTION DE LA RÉCLAMATION
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      claim.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Immatriculation du véhicule
            Row(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  claim.registrationNumber.isNotEmpty
                      ? claim.registrationNumber
                      : claim.vehicleNo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4. Service
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    claim.serviceName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Agence et Date
            Row(
              children: [
                // Agence
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          claim.agencyName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Date
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          claim.creationDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 6. Priorité
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: pColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: pColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        claim.priority == 2
                            ? Icons.priority_high_rounded
                            : claim.priority == 1
                            ? Icons.remove_rounded
                            : Icons.low_priority_rounded,
                        size: 14,
                        color: pColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        claim.priorityLabel,
                        style: TextStyle(
                          color: pColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}