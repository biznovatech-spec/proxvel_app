import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/inputs/proxvel_text_field.dart';
import '../../core/widgets/buttons/proxvel_button.dart';
import '../../core/utils/avatar_picker_helper.dart';
import '../../integration/services/peru_location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedDepartment;
  String? _selectedProvince;
  String? _selectedCity;

  List<String> _departments = [];
  List<String> _provinces = [];
  List<String> _cities = [];
  bool _isLocationsLoaded = false;
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
          _nameController.text = parts[0];
          _lastNameController.text = parts.skip(1).join(' ');
        }

        _emailController.text = user.email;
      }
      _loadLocations(user?.residenceDepartment, user?.residenceProvince, user?.residenceCity);
    });
  }

  Future<void> _loadLocations(String? dept, String? prov, String? city) async {
    final service = PeruLocationService();
    await service.init();
    
    if (mounted) {
      setState(() {
        _departments = service.getDepartments();
        _isLocationsLoaded = true;
        
        if (dept != null && _departments.contains(dept)) {
          _selectedDepartment = dept;
          _provinces = service.getProvinces(dept);
          
          if (prov != null && _provinces.contains(prov)) {
            _selectedProvince = prov;
            _cities = service.getDistricts(dept, prov);
            
            if (city != null && _cities.contains(city)) {
              _selectedCity = city;
            }
          }
        }
      });
    }
  }

  void _onDepartmentChanged(String? value) {
    setState(() {
      _selectedDepartment = value;
      _selectedProvince = null;
      _selectedCity = null;
      _provinces = value != null ? PeruLocationService().getProvinces(value) : [];
      _cities = [];
    });
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedCity = null;
      _cities = value != null && _selectedDepartment != null 
          ? PeruLocationService().getDistricts(_selectedDepartment!, value) 
          : [];
    });
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    await context.read<AuthController>().updateUserProfile(
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      residenceDepartment: _selectedDepartment,
      residenceProvince: _selectedProvince,
      residenceCity: _selectedCity,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              items: items.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              )).toList(),
              onChanged: enabled ? onChanged : null,
              hint: Text('Seleccionar $label', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
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
              fillColor: const Color(0xFFF3F4F6),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF), size: 20),
              helperText: 'El correo no se puede modificar',
            ),
            const SizedBox(height: 32),
            const Text(
              'Residencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLocationsLoaded)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else ...[
              _buildDropdown(
                label: 'Departamento',
                value: _selectedDepartment,
                items: _departments,
                onChanged: _onDepartmentChanged,
                enabled: true,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Provincia',
                value: _selectedProvince,
                items: _provinces,
                onChanged: _onProvinceChanged,
                enabled: _selectedDepartment != null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Ciudad / Distrito',
                value: _selectedCity,
                items: _cities,
                onChanged: _onCityChanged,
                enabled: _selectedProvince != null,
              ),
            ],
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
