import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/widgets/inputs/proxvel_text_field.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import 'widgets/auth_layout_wrapper.dart';
import 'widgets/social_auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
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

  // Password Requirements State
  bool _hasMinLength = false;
  bool _hasComplexChars = false;
  bool _repeats23Times = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    
    setState(() {
      _hasMinLength = pass.length >= 8;
      
      final hasUpper = pass.contains(RegExp(r'[A-Z]'));
      final hasNumber = pass.contains(RegExp(r'[0-9]'));
      final hasSymbol = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasComplexChars = hasUpper && hasNumber && hasSymbol;

      _repeats23Times = pass.isNotEmpty && confirm == pass;
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 0);
    } else {
      context.pop();
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
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
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      titleWidget: const Text(
        'Crea una cuenta\ncon nosotros.',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.1,
        ),
      ),
      showBackButton: true,
      expandContent: true,
      cropImageToTop: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Formularios: se expanden para llenar el espacio disponible
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFormStep1(),
                _buildFormStep2(),
              ],
            ),
          ),
          // Botones: anclados al fondo, sin altura fija
          AnimatedCrossFade(
            firstChild: _buildButtonsStep1(),
            secondChild: _buildButtonsStep2(),
            crossFadeState: _currentStep == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
          ),
        ],
      ),
    );
  }

  Widget _buildFormStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(1, 'Datos Personales'),
          const SizedBox(height: 12),
          _buildInfoBox('Usaremos este correo para crear tu cuenta de forma segura.', Icons.lock_outline),
          const SizedBox(height: 16),
          ProxvelTextField(label: 'Nombre', controller: _nameController),
          ProxvelTextField(label: 'Apellidos', controller: _lastnameController),
          ProxvelTextField(label: 'Email', controller: _emailController),
        ],
      ),
    );
  }

  Widget _buildFormStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(2, 'Crear Contraseña'),
          const SizedBox(height: 12),
          _buildInfoBox('Crea una contraseña fuerte para tu cuenta.', Icons.security),
          const SizedBox(height: 16),
          ProxvelTextField(
            label: 'Contraseña',
            controller: _passwordController,
            isPassword: true,
          ),
          ProxvelTextField(
            label: 'Confirmar contraseña',
            controller: _confirmPasswordController,
            isPassword: true,
          ),
          const Text(
            'Requisitos de contraseña',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('Mínimo 8 caracteres', _hasMinLength),
          _buildRequirementItem('1 mayúscula, 1 número y 1 símbolo', _hasComplexChars),
          _buildRequirementItem('La contraseña se debe repetir 23 veces', _repeats23Times),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                  activeColor: const Color(0xFF2B323B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Acepto los términos y condiciones',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ProxvelButton(
          text: 'Siguiente →',
          onPressed: _nextStep,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialAuthButton(iconPath: 'assets/icons/ic_google.svg', onTap: () {}),
            const SizedBox(width: 24),
            SocialAuthButton(iconPath: 'assets/icons/ic_github.svg', onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Color(0xFF6B7280))),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonsStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ProxvelButton(
          text: 'Registrarme',
          isLoading: _isLoading,
          onPressed: _acceptTerms && _hasMinLength && _hasComplexChars && _repeats23Times
              ? _handleRegister
              : null,
        ),
        const SizedBox(height: 16),
        ProxvelButton(
          text: 'Volver',
          isSecondary: true,
          onPressed: _prevStep,
        ),
      ],
    );
  }

  Widget _buildStepHeader(int step, String title) {
    return Row(
      children: [
        Text(
          'Paso $step de 2 - ',
          style: const TextStyle(
            color: Color(0xFF9CA3AF), // Gray-400
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFF59E0B), // Amber/Orange
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Very Light Gray
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)), // Light border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
