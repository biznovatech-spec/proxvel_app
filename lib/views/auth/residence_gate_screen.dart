import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../core/widgets/images/proxvel_enhanced_image.dart';
import '../../core/widgets/buttons/shimmer_button.dart';
import '../../core/widgets/forms/residence_fields_widget.dart';

class ResidenceGateScreen extends StatefulWidget {
  const ResidenceGateScreen({super.key});

  @override
  State<ResidenceGateScreen> createState() => _ResidenceGateScreenState();
}

class _ResidenceGateScreenState extends State<ResidenceGateScreen> with TickerProviderStateMixin {
  String? _selectedDepartment;
  String? _selectedProvince;
  String? _selectedCity;

  bool _isLoading = false;
  late final AnimationController _shimmerCtrl;

  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberDark = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _selectedDepartment != null && _selectedProvince != null && _selectedCity != null;

  Future<void> _handleSave() async {
    if (!_canSave) return;
    
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthController>().currentUser;
      if (user == null) throw Exception('No session');

      await context.read<AuthController>().updateUserProfile(
        name: user.name,
        lastName: user.lastName,
        email: user.email,
        residenceDepartment: _selectedDepartment,
        residenceProvince: _selectedProvince,
        residenceCity: _selectedCity,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/main');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos guardar tu residencia. Intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await context.read<AuthController>().logout();
    if (mounted) {
      context.go('/welcome');
    }
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
          // Background Image
          Positioned.fill(
            child: const ProxvelEnhancedImage(
              imagePath: 'assets/images/welcome.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Gradient
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
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
                            onPressed: _handleLogout,
                            tooltip: 'Cerrar sesión',
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Completa tu\nresidencia',
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
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Usaremos tu residencia para adaptar recomendaciones y evitar sugerirte siempre lugares de tu propia zona. No usaremos GPS en este paso.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
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

                      const SizedBox(height: 32),

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ResidenceFieldsWidget(
                            onChanged: (dept, prov, city) {
                              setState(() {
                                _selectedDepartment = dept;
                                _selectedProvince = prov;
                                _selectedCity = city;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: _amber))
                          : Opacity(
                              opacity: _canSave ? 1.0 : 0.5,
                              child: ShimmerButton(
                                shimmer: _shimmerCtrl,
                                baseColor: _amber,
                                hoverColor: _amberDark,
                                text: 'Guardar y continuar',
                                onPressed: _canSave ? _handleSave : () {},
                              ),
                            ),
                      ),

                      const SizedBox(height: 48),
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
