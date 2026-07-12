import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProxvelBrandedLoading extends StatefulWidget {
  final String message;
  final String? submessage;
  final bool compact;
  final bool showLogo;
  final bool dark;

  const ProxvelBrandedLoading({
    super.key,
    this.message = 'Preparando tu próxima experiencia...',
    this.submessage,
    this.compact = false,
    this.showLogo = true,
    this.dark = true,
  });

  @override
  State<ProxvelBrandedLoading> createState() => _ProxvelBrandedLoadingState();
}

class _ProxvelBrandedLoadingState extends State<ProxvelBrandedLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.dark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final textColor = widget.dark ? Colors.white : const Color(0xFF1F2937);
    final subtextColor = widget.dark ? Colors.white70 : const Color(0xFF4B5563);
    final accentColor = const Color(0xFFF59E0B); // Amber/Golden

    if (widget.compact) {
      return Center(
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (_pulseCtrl.value * 0.5),
              child: child,
            );
          },
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: accentColor,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showLogo) ...[
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (_pulseCtrl.value * 0.3),
                    child: Transform.scale(
                      scale: 0.96 + (_pulseCtrl.value * 0.04),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/proxvel_logo_transparente.png',
                  width: 140,
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.6 + (_pulseCtrl.value * 0.4),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: accentColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                decoration: TextDecoration.none, // En caso de que se use sin un Material App ancestor
              ),
            ),
            if (widget.submessage != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.submessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: subtextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
