import 'package:flutter/material.dart';

/// Marcador de mapa con animación de entrada (escala elástica).
///
/// Widget compartido por `MapScreen` y `DestinationMapScreen` para evitar
/// duplicación. El `onTap` es opcional (algunos mapas son solo de lectura)
/// y el `icon` permite distinguir destino vs. ubicación del usuario.
class AnimatedMapMarker extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  final IconData icon;

  const AnimatedMapMarker({
    super.key,
    this.onTap,
    required this.color,
    this.icon = Icons.location_on,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}
