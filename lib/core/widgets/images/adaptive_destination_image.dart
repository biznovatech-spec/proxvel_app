import 'package:flutter/material.dart';

/// Imagen de destino que resuelve automáticamente la fuente:
/// - URL http(s) → Image.network (imágenes del backend / Wikimedia)
/// - ruta local → Image.asset (mocks y assets del diseño)
///
/// Mantiene el mismo fit/alignment y muestra un placeholder neutro
/// si la imagen de red falla o mientras carga.
class AdaptiveDestinationImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;

  const AdaptiveDestinationImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return _placeholder();

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }

    return Image.asset(
      imagePath,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder({Widget? child}) => Container(
        color: const Color(0xFFE8ECEF),
        child: child ??
            const Center(
              child: Icon(Icons.landscape_outlined,
                  size: 40, color: Color(0xFFB0BEC5)),
            ),
      );
}
