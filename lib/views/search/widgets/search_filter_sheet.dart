import 'package:flutter/material.dart' hide SearchController;
import '../../../controllers/search_controller.dart' show SearchController, SearchFilters;
import '../../../core/theme/app_colors.dart';

/// Bottom sheet with visual filter chips for search refinement.
class SearchFilterSheet extends StatefulWidget {
  final SearchController controller;

  const SearchFilterSheet({super.key, required this.controller});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String? _city;
  late String? _category;
  late String? _climate;
  late double? _maxBudget;
  late int? _minCompat;

  @override
  void initState() {
    super.initState();
    final f = widget.controller.filters;
    _city = f.city;
    _category = f.category;
    _climate = f.climate;
    _maxBudget = f.maxBudget;
    _minCompat = f.minCompatibility;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title row
            Row(
              children: [
                const Text(
                  'Filtrar resultados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _city = null;
                    _category = null;
                    _climate = null;
                    _maxBudget = null;
                    _minCompat = null;
                  }),
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Ciudad ──
            _sectionLabel('Ciudad / Región'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.availableCities
                  .map((c) => _filterChip(c, _city == c, () {
                        setState(() => _city = _city == c ? null : c);
                      }))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Categoría ──
            _sectionLabel('Categoría'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.availableCategories
                  .map((c) => _filterChip(c, _category == c, () {
                        setState(() => _category = _category == c ? null : c);
                      }))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Clima ──
            _sectionLabel('Clima'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.availableClimates
                  .map((c) => _filterChip(c, _climate == c, () {
                        setState(() => _climate = _climate == c ? null : c);
                      }))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Presupuesto ──
            _sectionLabel('Presupuesto máximo'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 200, 500, 1000]
                  .map((v) => _filterChip(
                      'S/ $v',
                      _maxBudget == v.toDouble(),
                      () => setState(() => _maxBudget =
                          _maxBudget == v.toDouble() ? null : v.toDouble())))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── Compatibilidad mínima ──
            _sectionLabel('Compatibilidad mínima'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [60, 70, 80, 90]
                  .map((v) => _filterChip('≥ $v%', _minCompat == v,
                      () => setState(() => _minCompat = _minCompat == v ? null : v)))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // ── Apply button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GestureDetector(
                onTap: () {
                  final newFilters = SearchFilters(
                    query: ctrl.filters.query,
                    city: _city,
                    category: _category,
                    climate: _climate,
                    maxBudget: _maxBudget,
                    minCompatibility: _minCompat,
                  );
                  ctrl.search(newFilters: newFilters);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Aplicar filtros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
