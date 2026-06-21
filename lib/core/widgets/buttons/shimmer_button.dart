import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShimmerButton extends StatelessWidget {
  final AnimationController shimmer;
  final Color baseColor;
  final Color hoverColor;
  final VoidCallback onPressed;
  final String text;

  const ShimmerButton({
    super.key,
    required this.shimmer,
    required this.baseColor,
    required this.hoverColor,
    required this.onPressed,
    this.text = 'Comenzar',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              // Botón base
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: baseColor,
                  foregroundColor: Colors.black, // Dark text is standard for amber button
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    hoverColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: Colors.black, // Keep it black for contrast against amber
                  ),
                ),
              ),

              // Shimmer sweep (no intercepta toques)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: shimmer,
                  builder: (_, child) {
                    final t = shimmer.value;
                    final sweepX = -0.4 + t * 1.8;
                    return SizedBox.expand(
                      child: CustomPaint(
                        painter: _SweepPainter(position: sweepX),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  final double position; // 0.0 = izquierda, 1.0 = derecha

  const _SweepPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final x = position * size.width;
    final sweepWidth = size.width * 0.38;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(x - sweepWidth / 2, 0, sweepWidth, size.height),
      );

    // Inclina el sweep ~20°
    final path = Path()
      ..moveTo(x - sweepWidth / 2 - 8, 0)
      ..lineTo(x + sweepWidth / 2 + 8, 0)
      ..lineTo(x + sweepWidth / 2 - 8, size.height)
      ..lineTo(x - sweepWidth / 2 - 24, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.position != position;

  @override
  bool hitTest(Offset position) => false;
}
