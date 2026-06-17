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
  String _days = '';
  bool _applyAi = false;

  final List<String> _budgetOptions = ['Bajo', 'Medio', 'Alto', 'Lujo'];
  final List<String> _climateOptions = ['Frío', 'Templado', 'Cálido'];
  final List<String> _crowdOptions = ['Baja', 'Media', 'Alta'];
  final List<String> _daysOptions = ['1', '2', '3', '5', '7+'];
  final List<String> _allInterests = [
    'Naturaleza',
    'Cultura',
    'Gastronomía',
    'Compras',
    'Aventura',
    'Playa',
    'Urbano',
    'Rural',
    'Negocios',
    'Académico',
    'Relax',
    'Familiar',
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
        _budget = _matchOption(_budgetOptions, profile.presupuesto) ?? '';
        _climate = _matchOption(_climateOptions, profile.climaPreferido) ?? '';
        _crowdTolerance =
            _matchOption(_crowdOptions, profile.toleranciaMultitudes) ?? '';

        final days = profile.diasViaje;
        _days = days >= 7 ? '7+' : days.toString();
        if (!_daysOptions.contains(_days)) _days = '3'; // Default fallback

        // Intereses
        _interests = profile.intereses
            .map((i) => _matchOption(_allInterests, i))
            .where((i) => i != null)
            .cast<String>()
            .toList();

        _applyAi = profile.applyAiGlobally;
      });
    }
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  String? _matchOption(List<String> options, String backendValue) {
    final normalized = _normalize(backendValue);
    for (final opt in options) {
      final optNorm = _normalize(opt);
      if (optNorm == normalized) {
        return opt;
      }
      // Especial caso: alto/alta, bajo/baja, medio/media
      if ((optNorm == 'alta' && normalized == 'alto') ||
          (optNorm == 'baja' && normalized == 'bajo') ||
          (optNorm == 'media' && normalized == 'medio')) {
        return opt;
      }
    }
    return null;
  }

  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final tipoInteres = _interests.isEmpty
          ? 'mixto'
          : (_interests.length == 1 ? _normalize(_interests.first) : 'mixto');

      String mapCrowd(String val) {
        final lower = _normalize(val);
        if (lower == 'alta') return 'alto';
        if (lower == 'media') return 'medio';
        if (lower == 'baja') return 'bajo';
        return lower;
      }

      int parseDays(String val) {
        if (val == '7+') return 7;
        return int.tryParse(val) ?? 3;
      }

      final validInterests = _interests
          .where((i) => _allInterests.contains(i))
          .map((e) => _normalize(e))
          .toList();

      final updated = TravelerProfileModel(
        presupuesto: _budget.isEmpty ? 'medio' : _normalize(_budget),
        diasViaje: parseDays(_days),
        climaPreferido: _climate.isEmpty ? 'templado' : _normalize(_climate),
        tipoInteres: tipoInteres,
        intereses: validInterests.isEmpty ? ['playa'] : validInterests,
        toleranciaMultitudes: _crowdTolerance.isEmpty
            ? 'medio'
            : mapCrowd(_crowdTolerance),
        // Preservar la preferencia de IA en el PUT (si no, el backend la limpiaría).
        applyAiGlobally: _applyAi,
      );

      await context.read<ProfileController>().updatePreferences(updated);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias actualizadas correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            const SnackBar(
              content: Text('Puedes seleccionar máximo 5 intereses'),
            ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mis Preferencias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // ── Switch maestro de IA ──
            _buildAiSwitch(),
            const SizedBox(height: 24),

            _buildSectionTitle(
              'Presupuesto de viaje',
              Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 12),
            _buildSelectionGrid(
              _budgetOptions,
              _budget,
              (val) => setState(() => _budget = val),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Días de viaje', Icons.calendar_month_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(
              _daysOptions,
              _days,
              (val) => setState(() => _days = val),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Clima preferido', Icons.thermostat_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(
              _climateOptions,
              _climate,
              (val) => setState(() => _climate = val),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Tolerancia a multitudes', Icons.groups_rounded),
            const SizedBox(height: 12),
            _buildSelectionGrid(
              _crowdOptions,
              _crowdTolerance,
              (val) => setState(() => _crowdTolerance = val),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Tus Intereses (Máx 5)', Icons.favorite_rounded),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _allInterests
                  .map((i) => _buildInterestChip(i))
                  .toList(),
            ),

            const SizedBox(height: 48),
            if (_isEditing) ...[
              ProxvelButton(
                text: _isSaving ? 'Guardando...' : 'Guardar Preferencias',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 16),
              ProxvelButton(
                text: 'Cancelar',
                isSecondary: true,
                onPressed: _isSaving
                    ? null
                    : () {
                        _loadCurrentPreferences();
                        setState(() => _isEditing = false);
                      },
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aplicar IA en toda la app',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ordena Explorar y Búsqueda por compatibilidad. No afecta "Para ti".',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _applyAi,
            activeThumbColor: AppColors.accent,
            onChanged: (val) async {
              setState(() => _applyAi = val);
              try {
                await context.read<ProfileController>().setApplyAiGlobally(val);
              } catch (e) {
                if (mounted) {
                  setState(() => _applyAi = !val); // revertir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No se pudo guardar la preferencia: ${e.toString().replaceAll("Exception: ", "")}',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
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

  Widget _buildSelectionGrid(
    List<String> options,
    String currentValue,
    Function(String) onSelect,
  ) {
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
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textOnDark
                    : AppColors.textSecondary,
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
              const Icon(
                Icons.check_rounded,
                color: AppColors.accent,
                size: 16,
              ),
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
