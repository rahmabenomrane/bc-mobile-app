import 'package:flutter/material.dart';
import '../Service/claim_service.dart';
import '../models/claim_model.dart';
import 'AppFooter.dart';
import 'create_claim_screen.dart';

class ClaimsListScreen extends StatefulWidget {
  const ClaimsListScreen({super.key,this.onNavigate,});
  final Function(int)? onNavigate;

  @override
  State<ClaimsListScreen> createState() => _ClaimsListScreenState();
}

class _ClaimsListScreenState extends State<ClaimsListScreen> {
  List<ClaimModel> _claims = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() { _loading = true; _error = null; });
    try {
      final claims = await ClaimService.fetchClaims();
      setState(() => _claims = claims);
    } catch (e) {

      if (e.toString().contains('401') ||
          e.toString().contains('Session expirée')) {
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
            onPressed: _loadClaims,
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
      bottomNavigationBar:
      SizedBox(
        height: 95,
        child: AppFooter(
          currentIndex: 0,
          onTap: (i) {
            widget.onNavigate?.call(i);
            Navigator.pop(context);
          },
        ),
      )

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
              onPressed: _loadClaims,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ]),
        ),
      );
    }

    // Liste vide — message clair
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
      onRefresh: _loadClaims,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _claims.length,
        itemBuilder: (context, i) => _ClaimCard(claim: _claims[i]),
      ),
    );
  }

  Future<void> _goToCreate() async {
    final created = await Navigator.push<ClaimModel>(
      context,
      MaterialPageRoute(builder: (_) => const CreateClaimScreen()),
    );
    if (created != null) {
      await _loadClaims();
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
class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  const _ClaimCard({required this.claim});

  static const _statusColor = {
    0: Color(0xFF1565C0),
    1: Color(0xFF2E7D32),
    2: Color(0xFF546E7A),
    3: Color(0xFFA32D2D),
  };
  static const _statusBg = {
    0: Color(0xFFE3F2FD),
    1: Color(0xFFE8F5E9),
    2: Color(0xFFECEFF1),
    3: Color(0xFFFCEBEB),
  };
  static const _priorityColor = {
    0: Color(0xFF388E3C),
    1: Color(0xFFF57F17),
    2: Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor[claim.status] ?? Colors.grey;
    final sBg    = _statusBg[claim.status]    ?? Colors.grey.shade100;
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // En-tête
          Row(children: [
            Text('#${claim.claimNumber}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFFA32D2D))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: sBg, borderRadius: BorderRadius.circular(20)),
              child: Text(claim.statusLabel,
                  style: TextStyle(
                      color: sColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),

          // Description
          Text(claim.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: Colors.black87)),
          const SizedBox(height: 12),

          // Pied
          Row(children: [
            Icon(Icons.directions_car_outlined,
                size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              claim.vehicleDisplay,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 14),
            Icon(Icons.calendar_today_outlined,
                size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(claim.creationDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: pColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(claim.priorityLabel,
                  style: TextStyle(
                      color: pColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
    );
  }
}