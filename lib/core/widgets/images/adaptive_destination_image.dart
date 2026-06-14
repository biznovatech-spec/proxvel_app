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
  final double? width;
  final double? height;

  const AdaptiveDestinationImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return _placeholder();

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(); // Clean placeholder without eternal spinner
        },
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _placeholder({Widget? child}) => SizedBox(
        width: width,
        height: height,
        child: Container(
          color: const Color(0xFFE8ECEF),
          child: child ??
              const Center(
                child: Icon(Icons.landscape_outlined,
                    size: 40, color: Color(0xFFB0BEC5)),
              ),
        ),
      );
}
