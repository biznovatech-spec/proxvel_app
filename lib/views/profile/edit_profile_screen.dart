import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/inputs/proxvel_text_field.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import '../../core/utils/avatar_picker_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        final fullName = user.fullName.trim();
        final parts = fullName.split(RegExp(r'\s+'));

        if (parts.length == 1) {
          _nameController.text = parts[0];
          _lastNameController.text = '';
        } else if (parts.length == 2) {
          _nameController.text = parts[0];
          _lastNameController.text = parts[1];
        } else if (parts.length > 2) {
          // Rule: First word is Name, the rest is Last Name
          _nameController.text = parts[0];
          _lastNameController.text = parts.skip(1).join(' ');
        }

        _emailController.text = user.email;
      }
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    await context.read<AuthController>().updateUserProfile(
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => pickAndUploadAvatar(context),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                        image: context.watch<AuthController>().currentUser?.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(context.watch<AuthController>().currentUser!.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: context.watch<AuthController>().currentUser?.avatarUrl == null
                          ? const Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: AppColors.accent,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ProxvelTextField(label: 'Nombre', controller: _nameController),
            const SizedBox(height: 16),
            ProxvelTextField(
              label: 'Apellidos',
              controller: _lastNameController,
            ),
            const SizedBox(height: 16),
            ProxvelTextField(
              label: 'Email',
              controller: _emailController,
              readOnly: true,
              fillColor: const Color(0xFFF3F4F6), // gris muteado
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF), size: 20),
              helperText: 'El correo no se puede modificar',
            ),
            const SizedBox(height: 48),
            ProxvelButton(
              text: 'Guardar cambios',
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
