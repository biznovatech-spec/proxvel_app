import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../core/widgets/images/proxvel_enhanced_image.dart';
import '../../core/widgets/buttons/shimmer_button.dart';
import '../../core/widgets/inputs/glass_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  String? _loginError;
  String? _emailError;
  String? _passwordError;

  // Reusing the amber color from welcome screen
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberDark = Color(0xFFD97706);

  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  String _sanitizeAuthError(Object error) {
    String rawError = error.toString();
    rawError = rawError.replaceAll('Exception: ', '').replaceAll('ApiException: ', '').trim();
    
    if (rawError.isEmpty) {
      return 'No pudimos completar la acción. Intenta nuevamente.';
    }

    final lower = rawError.toLowerCase();

    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception') ||
        lower.contains('timeout') ||
        lower.contains('handshake')) {
      return 'No hay conexión con el servidor. Verifica tu internet e intenta nuevamente.';
    }

    if (lower.contains('typeerror') ||
        lower.contains('formatexception') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('null is not a subtype') ||
        lower.contains('stack trace') ||
        lower.contains('traceback') ||
        lower.contains('sql') ||
        lower.contains('database') ||
        lower.contains('internal server error')) {
      return 'Ocurrió un problema inesperado. Intenta nuevamente.';
    }

    if (rawError.length > 150) {
      return 'No pudimos completar la acción. Intenta nuevamente.';
    }

    return rawError;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'El correo es requerido' : null;
      _passwordError = _passwordController.text.isEmpty ? 'La contraseña es requerida' : null;
      _loginError = null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    final error = await context.read<AuthController>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        setState(() => _loginError = _sanitizeAuthError(error));
      } else {
        context.go('/main');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          // ── Fullscreen Background Image ──
          Positioned.fill(
            child: ProxvelEnhancedImage(
              imagePath: 'assets/images/welcome.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ── Cinematic Bottom Dark Gradient ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.55, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Action Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          '¡Bienvenido de\nnuevo!',
                          style: GoogleFonts.poppins(
                            fontSize: 34,
                            height: 1.18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Continua tu aventura',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Column(
                          children: [
                            GlassTextField(
                              label: 'Email',
                              controller: _emailController,
                              errorText: _emailError,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) {
                                if (_emailError != null) setState(() => _emailError = null);
                                if (_loginError != null) setState(() => _loginError = null);
                              },
                            ),
                            const SizedBox(height: 20),
                            GlassTextField(
                              label: 'Contraseña',
                              controller: _passwordController,
                              isPassword: true,
                              errorText: _passwordError,
                              onChanged: (val) {
                                if (_passwordError != null) setState(() => _passwordError = null);
                                if (_loginError != null) setState(() => _loginError = null);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Error Message
                      if (_loginError != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0).copyWith(top: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _loginError!,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFF6B6B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Options (Remember me & Forgot password)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) {
                                      setState(() => _rememberMe = val ?? false);
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                                    activeColor: _amber,
                                    checkColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Recordar sesión',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: _amber))
                          : ShimmerButton(
                              shimmer: _shimmerCtrl,
                              baseColor: _amber,
                              hoverColor: _amberDark,
                              text: 'Iniciar Sesión',
                              onPressed: _handleLogin,
                            ),
                      ),

                      const SizedBox(height: 36),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes una cuenta? ',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Regístrate',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
