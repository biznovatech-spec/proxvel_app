import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../theme/app_colors.dart';

/// Flujo unificado para elegir y subir una foto de perfil.
Future<void> pickAndUploadAvatar(BuildContext context) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70, // Reducir peso
  );

  if (pickedFile == null || !context.mounted) return;

  // Mostramos un SnackBar de carga
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 16),
          Text('Subiendo imagen de perfil...'),
        ],
      ),
      duration: Duration(seconds: 10),
    ),
  );

  try {
    final authCtrl = context.read<AuthController>();
    await authCtrl.uploadAvatar(pickedFile.path);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar actualizado con éxito')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
    );
  }
}
