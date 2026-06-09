import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import 'widgets/auth_layout_wrapper.dart';
import 'widgets/social_auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      titleWidget: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            height: 1.2,
          ),
          children: [
            TextSpan(
              text: 'Comienza tu\n',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'próxima aventura',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      showBackButton: false,
      topBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'PROXVEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubre destinos increíbles recomendados solo para ti.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280), // Gray-500
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ProxvelButton(
            text: 'Iniciar Sesión',
            onPressed: () => context.push('/login'),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'O conéctate con',
              style: TextStyle(
                color: Color(0xFF9CA3AF), // Gray-400
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes cuenta? ',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: const Row(
                  children: [
                    Text(
                      'Regístrate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937), // Gray-800
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1F2937)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
