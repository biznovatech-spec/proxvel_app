import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Breve pausa para no pestañear la pantalla si carga muy rápido
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final authController = context.read<AuthController>();
    
    // Si es la primera vez que se abre la app, mostramos el intro (si la app lo tiene)
    // Pero en PROXVEL, el intro es '/intro'.
    // De momento, la orden es verificar sesión:
    final restored = await authController.restoreSession();
    
    if (!mounted) return;
    
    if (restored) {
      context.go('/main');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 24),
            Text(
              'Verificando sesión...',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
