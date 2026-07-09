import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/images/proxvel_enhanced_image.dart';
import '../../core/widgets/buttons/shimmer_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberDark = Color(0xFFD97706);

  // Ken Burns — zoom lento sobre la foto
  late final AnimationController _kenBurnsCtrl;
  late final Animation<double> _kenBurnsScale;
  late final Animation<Offset> _kenBurnsOffset;

  // Entrada escalonada — título, subtítulo, botón
  late final AnimationController _entranceCtrl;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _ctaOpacity;
  late final Animation<Offset> _ctaSlide;

  // Shimmer en el botón
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();

    // ── Ken Burns (12s loop suave) ──
    _kenBurnsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _kenBurnsScale = Tween<double>(begin: 1.05, end: 1.12).animate(
      CurvedAnimation(parent: _kenBurnsCtrl, curve: Curves.easeInOut),
    );
    _kenBurnsOffset = Tween<Offset>(
      begin: const Offset(-0.02, -0.01),
      end: const Offset(0.02, 0.01),
    ).animate(
      CurvedAnimation(parent: _kenBurnsCtrl, curve: Curves.easeInOut),
    );

    // ── Entrada escalonada (1.4s total) ──
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));

    _subtitleOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
    ));

    _ctaOpacity = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.50, 0.90, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.50, 0.95, curve: Curves.easeOutCubic),
    ));

    // ── Shimmer en el botón (2.4s loop, arranca después de la entrada) ──
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Arranca todo
    _entranceCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _shimmerCtrl.repeat();
      });
    });
  }

  @override
  void dispose() {
    _kenBurnsCtrl.dispose();
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Ken Burns: foto con zoom lento ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _kenBurnsCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  _kenBurnsOffset.value.dx * MediaQuery.sizeOf(context).width,
                  _kenBurnsOffset.value.dy * MediaQuery.sizeOf(context).height,
                ),
                child: Transform.scale(
                  scale: _kenBurnsScale.value,
                  child: child,
                ),
              ),
              child: const ProxvelEnhancedImage(
                imagePath: 'assets/images/welcome.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // ── Gradiente cinematográfico ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 0.68, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.58),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido con entrada escalonada ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),

                // Título
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'El Perú que siempre\nquisiste vivir.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          height: 1.18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtítulo
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Descubre los mejores destinos del Perú, todo en una app.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Botón con shimmer
                FadeTransition(
                  opacity: _ctaOpacity,
                  child: SlideTransition(
                    position: _ctaSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ShimmerButton(
                        shimmer: _shimmerCtrl,
                        baseColor: _amber,
                        hoverColor: _amberDark,
                        text: 'Comenzar',
                        onPressed: () => context.push('/register'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Enlace login
                FadeTransition(
                  opacity: _ctaOpacity,
                  child: GestureDetector(
                    onTap: () => context.push('/login'),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 28),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                          children: [
                            const TextSpan(text: '¿Ya tienes cuenta?  '),
                            TextSpan(
                              text: 'Inicia sesión',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
