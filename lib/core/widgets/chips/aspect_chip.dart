import 'package:flutter/material.dart';

class AspectChip extends StatelessWidget {
  final String label;
  const AspectChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
