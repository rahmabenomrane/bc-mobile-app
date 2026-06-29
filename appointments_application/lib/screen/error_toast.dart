import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ToastType { error, warning, success }

class AppToast {
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        ToastType type = ToastType.error,
        String? actionLabel,
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 4),
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        title: title,
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }

  // Dans error_toast.dart — modifie la méthode error()
  static void error(BuildContext context, String message) => show(
    context,
    title: _titleFor(message),
    message: message,
    type: ToastType.error,
    actionLabel: 'Retour à l\'accueil',
    onAction: () => Navigator.of(context).popUntil((route) => route.isFirst),
  );

  static void success(BuildContext context, String message) => show(
    context,
    title: 'Succès',
    message: message,
    type: ToastType.success,
  );

  static void warning(BuildContext context, String message) => show(
    context,
    title: 'Attention',
    message: message,
    type: ToastType.warning,
  );

  static String _titleFor(String raw) {
    if (raw.contains('pont')) return 'Aucun pont disponible';
    if (raw.contains('SocketException') || raw.contains('connexion')) return 'Erreur de connexion';
    if (raw.contains('401')) return 'Session expirée';
    if (raw.contains('404')) return 'Ressource introuvable';
    if (raw.contains('500')) return 'Erreur serveur';
    return 'Une erreur est survenue';
  }
}

// ─── Widget interne ─────────────────────────────────────────────────────────
class _ToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final ToastType type;
  final String? actionLabel;      // ✅
  final VoidCallback? onAction;   // ✅
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config(widget.type);

    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _opacity,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cfg.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cfg.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: cfg.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cfg.iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(cfg.icon, color: cfg.iconColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cfg.titleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.5,
                                    color: cfg.msgColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Icon(Icons.close_rounded,
                                size: 18, color: cfg.msgColor),
                          ),
                        ],
                      ),

                      // ✅ Bouton action
                      if (widget.actionLabel != null && widget.onAction != null) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _dismiss();
                            widget.onAction!();
                          },
                          child: Row(
                            children: [
                              Icon(Icons.home_rounded,
                                  size: 14, color: cfg.titleColor),
                              const SizedBox(width: 6),
                              Text(
                                widget.actionLabel!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: cfg.titleColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Config par type ─────────────────────────────────────────────────────────
class _ToastConfig {
  final Color bg, border, shadow, iconBg, iconColor, titleColor, msgColor;
  final IconData icon;
  const _ToastConfig({
    required this.bg,
    required this.border,
    required this.shadow,
    required this.iconBg,
    required this.iconColor,
    required this.titleColor,
    required this.msgColor,
    required this.icon,
  });
}

_ToastConfig _config(ToastType type) {
  switch (type) {
    case ToastType.error:
      return _ToastConfig(
        bg: const Color(0xFFFCEBEB),
        border: const Color(0xFFF7C1C1),
        shadow: const Color(0xFFE24B4A).withOpacity(0.15),
        iconBg: const Color(0xFFF7C1C1),
        iconColor: const Color(0xFFA32D2D),
        titleColor: const Color(0xFF791F1F),
        msgColor: const Color(0xFFA32D2D),
        icon: Icons.error_outline_rounded,
      );
    case ToastType.warning:
      return _ToastConfig(
        bg: const Color(0xFFFAEEDA),
        border: const Color(0xFFFAC775),
        shadow: const Color(0xFFBA7517).withOpacity(0.15),
        iconBg: const Color(0xFFFAC775),
        iconColor: const Color(0xFF854F0B),
        titleColor: const Color(0xFF633806),
        msgColor: const Color(0xFF854F0B),
        icon: Icons.warning_amber_rounded,
      );
    case ToastType.success:
      return _ToastConfig(
        bg: const Color(0xFFEAF3DE),
        border: const Color(0xFFC0DD97),
        shadow: const Color(0xFF639922).withOpacity(0.15),
        iconBg: const Color(0xFFC0DD97),
        iconColor: const Color(0xFF3B6D11),
        titleColor: const Color(0xFF27500A),
        msgColor: const Color(0xFF3B6D11),
        icon: Icons.check_circle_outline_rounded,
      );
  }
}