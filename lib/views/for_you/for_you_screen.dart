import 'package:flutter/material.dart';

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para Ti')),
      body: const Center(child: Text('Recomendaciones Simuladas')),
    );
  }
}
