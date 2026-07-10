import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/images/proxvel_enhanced_image.dart';
import '../../core/widgets/buttons/shimmer_button.dart';
import '../../core/widgets/inputs/glass_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  // Animación manual para evitar PageView rígido
  int _currentStep = 0;

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _isLoading = false;

  bool _isStep1Valid = false;

  // Password Strength State
  int _passwordStrength = 0; // 0: Weak, 1: Medium, 2: Strong
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.transparent;
  bool _passwordsMatch = false;

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

    _nameController.addListener(_validateStep1);
    _lastnameController.addListener(_validateStep1);
    _emailController.addListener(_validateStep1);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  void _validateStep1() {
    final isValid = _nameController.text.trim().isNotEmpty &&
        _lastnameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
    if (_isStep1Valid != isValid) {
      setState(() => _isStep1Valid = isValid);
    }
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    // Calculate strength
    int strength = 0;
    if (pass.length >= 6) strength++;
    if (pass.length >= 8 && pass.contains(RegExp(r'[A-Z]')) && pass.contains(RegExp(r'[0-9]'))) strength++;
    if (pass.length >= 10 && pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    String text = '';
    Color color = Colors.transparent;

    if (pass.isEmpty) {
      strength = 0;
      text = '';
      color = Colors.transparent;
    } else if (strength == 1) {
      text = 'Débil';
      color = const Color(0xFFEF4444); // Red
    } else if (strength == 2) {
      text = 'Segura';
      color = const Color(0xFFF59E0B); // Amber
    } else {
      text = 'Fuerte';
      color = const Color(0xFF10B981); // Green
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
      _passwordsMatch = pass.isNotEmpty && confirm == pass;
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    } else {
      context.pop();
    }
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

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthController>().register(
        name: _nameController.text.trim(),
        lastName: _lastnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = _sanitizeAuthError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            child: const ProxvelEnhancedImage(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Action Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                                onPressed: _prevStep,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Comienza tu\naventura.',
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                height: 1.18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 16,
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
                              'Únete a la nueva era del turismo',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.85),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Forms AnimatedSwitcher
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _currentStep == 0 
                                  ? KeyedSubtree(key: const ValueKey(0), child: _buildStep1())
                                  : KeyedSubtree(key: const ValueKey(1), child: _buildStep2()),
                            ),
                          ),

                          const SizedBox(height: 24),
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

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        children: [
          GlassTextField(
            label: 'Nombre',
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [TitleCaseTextInputFormatter()],
          ),
          const SizedBox(height: 20),
          GlassTextField(
            label: 'Apellidos',
            controller: _lastnameController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [TitleCaseTextInputFormatter()],
          ),
          const SizedBox(height: 20),
          GlassTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 32),
          
          // Next Button
          ShimmerButton(
            shimmer: _shimmerCtrl,
            baseColor: _amber,
            hoverColor: _amberDark,
            text: 'Siguiente Paso',
            onPressed: () {
              if (_isStep1Valid) {
                _nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Por favor, completa todos tus datos',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          
          const SizedBox(height: 36), // Exact space to link
          
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes una cuenta? ',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  'Inicia sesión',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final bool isReadyToSubmit = _acceptTerms && _passwordStrength > 0 && _passwordsMatch;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        children: [
          GlassTextField(
            label: 'Contraseña',
            controller: _passwordController,
            isPassword: true,
          ),
          
          // Password Strength Bar
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: index < _passwordStrength 
                                  ? _passwordStrengthColor 
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _passwordStrengthText,
                    style: GoogleFonts.poppins(
                      color: _passwordStrengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          GlassTextField(
            label: 'Confirmar contraseña',
            controller: _confirmPasswordController,
            isPassword: true,
          ),

          const SizedBox(height: 12),
          
          // Password match indicator
          if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch)
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Las contraseñas no coinciden',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
          
          // Terms & Conditions
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) {
                    setState(() => _acceptTerms = val ?? false);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  activeColor: _amber,
                  checkColor: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acepto los términos y condiciones',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Submit Button
          _isLoading 
            ? const Center(child: CircularProgressIndicator(color: _amber))
            : ShimmerButton(
                shimmer: _shimmerCtrl,
                baseColor: _amber,
                hoverColor: _amberDark,
                text: 'Completar Registro',
                onPressed: () {
                  if (isReadyToSubmit) {
                    _handleRegister();
                  } else {
                    String msg = 'Completa los datos de contraseña';
                    if (!_acceptTerms) {
                      msg = 'Debes aceptar los términos y condiciones';
                    } else if (!_passwordsMatch) {
                      msg = 'Las contraseñas no coinciden';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              
          const SizedBox(height: 36),
          
          // Invisible spacer to match step 1 height
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
