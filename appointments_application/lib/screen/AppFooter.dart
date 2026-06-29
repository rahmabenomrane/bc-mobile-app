import 'package:flutter/material.dart';

import '../config/Palette.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = width / 5;
        final centerX = itemWidth * currentIndex + itemWidth / 2;

        return Material(
          color: Colors.transparent,
          child: SizedBox(
            height:90,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // BARRE (claire + soft shadow)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Palette.loopColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                ),

                // CREUX ANIMÉ
                AnimatedBuilder(
                  animation: AlwaysStoppedAnimation(centerX),
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(width, 80),
                      painter: NavBarPainter(centerX),
                    );
                  },
                ),

                // ICÔNES
                Positioned.fill(
                  child: Row(
                    children: List.generate(5, (index) {
                      final isActive = index == currentIndex;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          child: SizedBox(
                            height: 35,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isActive ? 0 : 1,
                                child: Icon(
                                  _getIcon(index),
                                  color: Palette.secondPageTopIconColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),


                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  left: centerX - 30,
                  bottom: 30,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0.9, end: 1),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () => onTap(currentIndex),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Palette.secondPageContainerGradient1stColor,
                              Palette.secondPageContainerGradient2ndColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIcon(currentIndex),
                          color: Palette.secondPageIconColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.calendar_month_rounded;
      case 2:
        return Icons.person_rounded;
      case 3:
        return Icons.history_rounded;
      case 4:
        return Icons.map_rounded;
      default:
        return Icons.home;
    }
  }
}

class NavBarPainter extends CustomPainter {
  final double centerX;

  NavBarPainter(this.centerX);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(centerX - 45, 0);

    // courbe fluide (plus smooth)
    path.cubicTo(
      centerX - 25, 0,
      centerX - 25, 45,
      centerX, 45,
    );

    path.cubicTo(
      centerX + 25, 45,
      centerX + 25, 0,
      centerX + 45, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    // canvas.drawShadow(path, Colors.black.withOpacity(0.1), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX;
  }
}

