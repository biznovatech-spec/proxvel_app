import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/widgets/inputs/proxvel_text_field.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import 'widgets/auth_layout_wrapper.dart';
import 'widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  String? _loginError;
  String? _emailError;
  String? _passwordError;

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
        setState(() => _loginError = error);
      } else {
        context.go('/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      titleWidget: const Text(
        '¡Bienvenido de\nnuevo!',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      ),
      subtitle: 'Continua tu aventura',
      showBackButton: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProxvelTextField(
            label: 'Email',
            controller: _emailController,
            errorText: _emailError,
            onChanged: (val) {
              if (_emailError != null) setState(() => _emailError = null);
              if (_loginError != null) setState(() => _loginError = null);
            },
          ),
          ProxvelTextField(
            label: 'Contraseña',
            controller: _passwordController,
            isPassword: true,
            errorText: _passwordError,
            onChanged: (val) {
              if (_passwordError != null) setState(() => _passwordError = null);
              if (_loginError != null) setState(() => _loginError = null);
            },
          ),
          // Login error message
          if (_loginError != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _loginError!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (val) {
                    setState(() => _rememberMe = val ?? false);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFF9CA3AF)), // Gray-400
                  activeColor: const Color(0xFF2B323B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recordar sesión',
                style: TextStyle(
                  color: Color(0xFF6B7280), // Gray-500
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProxvelButton(
            text: 'Iniciar Sesión',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Color(0xFF1F2937), // Darker, matching original
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialAuthButton(
                iconPath: 'assets/icons/ic_google.svg',
                onTap: () {},
              ),
              const SizedBox(width: 24),
              SocialAuthButton(
                iconPath: 'assets/icons/ic_github.svg',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
