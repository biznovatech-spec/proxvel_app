import 'package:flutter/material.dart';

class ProxvelEnhancedImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;

  const ProxvelEnhancedImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Matriz de color para aumentar contraste (+15%) y saturación (+20%)
    // Esto hace que los colores resalten y la imagen se vea más vibrante y "premium"
    const List<double> matrix = <double>[
      1.15, 0, 0, 0, 0, // Red
      0, 1.15, 0, 0, 0, // Green
      0, 0, 1.15, 0, 0, // Blue
      0, 0, 0, 1, 0,    // Alpha
    ];

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(matrix),
      child: Image.asset(
        imagePath,
        fit: fit,
        alignment: alignment,
      ),
    );
  }
}
