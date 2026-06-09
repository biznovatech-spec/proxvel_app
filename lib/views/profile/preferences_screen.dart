import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/traveler_profile_model.dart';
import '../../core/widgets/buttons/proxvel_button.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isEditing = false;
  
  String _budget = '';
  String _climate = '';
  String _crowdTolerance = '';
  List<String> _interests = [];

  final List<String> _budgetOptions = ['Bajo', 'Medio', 'Alto', 'Lujo'];
  final List<String> _climateOptions = ['Soleado', 'Frío', 'Templado', 'Tropical'];
  final List<String> _crowdOptions = ['Baja', 'Media', 'Alta'];
  final List<String> _allInterests = [
    'Playa', 'Montaña', 'Ciudad', 'Aventura', 'Cultura', 'Gastronomía', 'Historia', 'Relajación'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPreferences();
    });
  }

  void _loadCurrentPreferences() {
    final profile = context.read<ProfileController>().profile;
    if (profile != null) {
      setState(() {
        _budget = profile.budget;
        _climate = profile.preferredClimate;
        _crowdTolerance = profile.crowdTolerance;
        _interests = List.from(profile.interests);
      });
    }
  }

  Future<void> _handleSave() async {
    final profile = context.read<ProfileController>().profile;
    final updated = TravelerProfileModel(
      budget: _budget.isEmpty ? 'Medio' : _budget,
      preferredClimate: _climate.isEmpty ? 'Templado' : _climate,
      crowdTolerance: _crowdTolerance.isEmpty ? 'Media' : _crowdTolerance,
      interests: _interests.isEmpty ? ['Playa'] : _interests,
      accessibility: profile?.accessibility ?? 'No requiere',
      experienceType: profile?.experienceType ?? 'Equilibrado',
    );
    await context.read<ProfileController>().updatePreferences(updated);
    
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias actualizadas'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_interests.contains(interest)) {
        _interests.remove(interest);
      } else {
        if (_interests.length < 5) {
          _interests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Puedes seleccionar máximo 5 intereses')),
          );
        }
      }
    });
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mis Preferencias',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.accent),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajusta cómo te recomendamos destinos basándonos en lo que más te gusta.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Presupuesto de viaje', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(_budgetOptions, _budget, (val) => setState(() => _budget = val)),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Clima preferido', Icons.thermostat_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(_climateOptions, _climate, (val) => setState(() => _climate = val)),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Tolerancia a multitudes', Icons.groups_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(_crowdOptions, _crowdTolerance, (val) => setState(() => _crowdTolerance = val)),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Tus Intereses (Máx 5)', Icons.favorite_rounded),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _allInterests.map((i) => _buildInterestChip(i)).toList(),
            ),

            const SizedBox(height: 48),
            if (_isEditing) ...[
              ProxvelButton(
                text: 'Guardar Preferencias',
                onPressed: _handleSave,
              ),
              const SizedBox(height: 16),
              ProxvelButton(
                text: 'Cancelar',
                isSecondary: true,
                onPressed: () {
                  _loadCurrentPreferences();
                  setState(() => _isEditing = false);
                },
              ),
              const SizedBox(height: 24),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionGrid(List<String> options, String currentValue, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == currentValue;
        return GestureDetector(
          onTap: _isEditing ? () => onSelect(opt) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterestChip(String interest) {
    final isSelected = _interests.contains(interest);
    return GestureDetector(
      onTap: _isEditing ? () => _toggleInterest(interest) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, color: AppColors.accent, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              interest,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
