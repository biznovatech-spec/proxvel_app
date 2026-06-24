import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/search_controller.dart' show SearchController, SearchFilters;
import '../../controllers/profile_controller.dart';
import '../../controllers/archive_controller.dart' as import_archive_controller;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/states/loading_view.dart';
import '../../core/widgets/states/proxvel_empty_state.dart';
import 'widgets/search_result_card.dart';
import 'widgets/search_filter_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _queryCtrl;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Asegura que el perfil esté cargado para poder gatear el orden IA.
      final profileCtrl = context.read<ProfileController>();
      if (profileCtrl.profile == null) profileCtrl.loadProfileData();

      final ctrl = context.read<SearchController>();
      ctrl.search(
        newFilters: SearchFilters(query: widget.initialQuery),
        aiSort: false,
        hasProfile: profileCtrl.profile != null,
      );
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  bool get _hasProfile => context.read<ProfileController>().profile != null;

  void _onSearch() {
    final ctrl = context.read<SearchController>();
    ctrl.search(
      newFilters: ctrl.filters.copyWith(query: _queryCtrl.text.trim()),
      aiSort: ctrl.aiSortEnabled,
      hasProfile: _hasProfile,
    );
  }

  void _onToggleAiSort(bool value) {
    final ctrl = context.read<SearchController>();
    ctrl.search(
      newFilters: ctrl.filters.copyWith(query: _queryCtrl.text.trim()),
      aiSort: value,
      hasProfile: _hasProfile,
    );
  }

  void _openFilters() {
    final ctrl = context.read<SearchController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => SearchFilterSheet(controller: ctrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final ctrl = context.watch<SearchController>();
    final archiveCtrl = context.watch<import_archive_controller.ArchiveController>();

    final filteredResults = ctrl.results
        .where((r) => !archiveCtrl.isArchived(r.destination.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(ctrl),
          Expanded(
            child: ctrl.isLoading
                ? const LoadingView()
                : filteredResults.isEmpty
                    ? ProxvelEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Sin resultados',
                        subtitle: ctrl.filters.hasActiveFilters
                            ? 'Prueba ajustando tus filtros\npara encontrar más destinos.'
                            : 'No encontramos destinos que\ncoincidan con tu búsqueda.',
                        actionLabel:
                            ctrl.filters.hasActiveFilters ? 'Limpiar filtros' : null,
                        onAction: ctrl.filters.hasActiveFilters
                            ? () => ctrl.clearFilters()
                            : null,
                      )
                    : _buildResultsList(ctrl, filteredResults),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SearchController ctrl) {
    final topPadding = MediaQuery.of(context).padding.top;
    final filterCount = ctrl.filters.activeFilterCount;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
          child: Column(
            children: [
              // ── Back + Title ──
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const Expanded(
                    child: Text(
                      'Buscar destinos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Search field + filter button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: TextField(
                          controller: _queryCtrl,
                          onSubmitted: (_) => _onSearch(),
                          style: const TextStyle(
                            color: AppColors.textOnDark,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: '¿A dónde viajas hoy?',
                            hintStyle: TextStyle(
                              color: AppColors.textOnDark.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: AppColors.accent, size: 22),
                            suffixIcon: _queryCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded,
                                        color: AppColors.textOnDark
                                            .withValues(alpha: 0.5),
                                        size: 20),
                                    onPressed: () {
                                      _queryCtrl.clear();
                                      _onSearch();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _openFilters,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: filterCount > 0
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.tune_rounded,
                                color: filterCount > 0
                                    ? AppColors.primary
                                    : AppColors.textOnDark,
                                size: 22),
                            if (filterCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$filterCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Toggle: Ordenar por recomendación IA ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ordenar por recomendación IA',
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: ctrl.aiSortEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: _onToggleAiSort,
                    ),
                  ],
                ),
              ),

              // ── Aviso: IA pedida sin perfil ──
              if (ctrl.aiBlockedNoProfile)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Completa tu perfil viajero para ordenar resultados con IA.',
                            style: TextStyle(
                              color: AppColors.textOnDark.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/profile/preferences'),
                          child: const Text(
                            'Completar',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Active filters summary ──
              if (ctrl.filters.hasActiveFilters) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      if (ctrl.filters.city != null)
                        _activeFilterChip(ctrl.filters.city!),
                      if (ctrl.filters.category != null)
                        _activeFilterChip(ctrl.filters.category!),
                      if (ctrl.filters.climate != null)
                        _activeFilterChip(ctrl.filters.climate!),
                      if (ctrl.filters.maxBudget != null)
                        _activeFilterChip(
                            '≤ S/ ${ctrl.filters.maxBudget!.toStringAsFixed(0)}'),
                      if (ctrl.filters.minCompatibility != null)
                        _activeFilterChip(
                            '≥ ${ctrl.filters.minCompatibility}%'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchController ctrl, List<dynamic> filteredResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            '${filteredResults.length} destino${filteredResults.length != 1 ? 's' : ''} encontrado${filteredResults.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredResults.length,
            itemBuilder: (_, i) {
              final item = filteredResults[i];
              final source = ctrl.aiSortEnabled ? 'ai_search' : 'search';
              return SearchResultCard(
                item: item,
                onTap: () => context.push(
                    '/destination/${item.destination.id}?source=$source'),
              );
            },
          ),
        ),
      ],
    );
  }
}
