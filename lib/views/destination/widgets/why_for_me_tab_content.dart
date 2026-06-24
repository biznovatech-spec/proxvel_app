import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/aspect_score_model.dart';
import '../../../models/traveler_profile_model.dart';
import 'ranking_header_card.dart';
import 'metric_circle_indicator.dart';
import 'aspect_score_grid.dart';
import 'influence_factor_item.dart';

/// Full content for the "¿Por qué para mí?" tab in the destination detail.
/// Assembles all sub-sections based on the prototype design.
class WhyForMeTabContent extends StatelessWidget {
  final int? rankPosition;
  final int compatibilityPercentage;
  final String label;
  final String explanation;
  final List<AspectScoreModel> aspectScores;
  final TravelerProfileModel? travelerProfile;
  final String destinationClimate;
  final String destinationCrowdLevel;

  // Contexto REAL del mes (clima + aforo), 0-1 (alto = mejor). NO de reseñas.
  final double? climaContextScore;
  final String? climaContextLabel;
  final double? aforoContextScore;
  final String? aforoContextLabel;
  final String? contextMonthName;

  const WhyForMeTabContent({
    super.key,
    this.rankPosition,
    required this.compatibilityPercentage,
    required this.label,
    required this.explanation,
    required this.aspectScores,
    this.travelerProfile,
    required this.destinationClimate,
    required this.destinationCrowdLevel,
    this.climaContextScore,
    this.climaContextLabel,
    this.aforoContextScore,
    this.aforoContextLabel,
    this.contextMonthName,
  });

  @override
  Widget build(BuildContext context) {
    // Afinidad: promedio de los aspectos ABSA. Clima/Aforo: CONTEXTO REAL del mes
    // (no de reseñas); si no llega, cae al ABSA como respaldo.
    final affinityScore = _calculateAffinity();
    final climateScore = climaContextScore != null
        ? (climaContextScore! * 100).round().clamp(0, 100)
        : _findAspectScore('Clima');
    final crowdScore = aforoContextScore != null
        ? (aforoContextScore! * 100).round().clamp(0, 100)
        : _findAspectScore('Aforo');
    // Etiqueta corta para que no se distorsione en el círculo (mes abreviado a 3 letras).
    final mesAbbr = (contextMonthName ?? '').isNotEmpty
        ? ' · ${contextMonthName!.length >= 3 ? contextMonthName!.substring(0, 3) : contextMonthName!}'
        : '';
    final climaLbl = 'Clima$mesAbbr';
    final aforoLbl = 'Aforo$mesAbbr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══ 1. Ranking Header Card ═══
        RankingHeaderCard(
          rankPosition: rankPosition,
          compatibilityPercentage: compatibilityPercentage,
          label: label,
        ),

        const SizedBox(height: 16),

        // Removed fake summary line

        // ═══ 3. ¿Por qué se recomienda? ═══
        if (explanation.isNotEmpty) ...[
          _buildSectionTitle('¿Por qué se recomienda?'),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // ═══ 4. Three metric circles ═══
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MetricCircleIndicator(
                  label: 'Afinidad base',
                  percentage: affinityScore,
                  icon: Icons.favorite_rounded,
                  color: AppColors.accent,
                ),
                MetricCircleIndicator(
                  label: climaLbl,
                  percentage: climateScore,
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.accent,
                ),
                MetricCircleIndicator(
                  label: aforoLbl,
                  percentage: crowdScore,
                  icon: Icons.groups_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        // ═══ 5. Factores que más influyen (dinámico, visual) ═══
        ..._buildInfluenceSection(),

        const SizedBox(height: 28),

        // ═══ 6. Aspectos turísticos evaluados ═══
        if (aspectScores.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle('Aspectos turísticos evaluados'),
              ),
              GestureDetector(
                onTap: () {
                  // Could show info dialog about ABSA
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textMuted, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: AspectScoreGrid(aspects: aspectScores),
          ),
        ],

        const SizedBox(height: 28),

        // ═══ Footer: model info ═══
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Modelo usado: WSM + similitud de perfil + re-ranking contextual',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 9,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Calculate overall affinity from the average of all aspect scores.
  int _calculateAffinity() {
    if (aspectScores.isEmpty) return 0;
    final avg =
        aspectScores.map((a) => a.score).reduce((a, b) => a + b) /
        aspectScores.length;
    return (avg * 100).round().clamp(0, 100);
  }

  /// Find a specific aspect's score by keyword.
  int? _findAspectScore(String keyword) {
    final lower = keyword.toLowerCase();
    for (final a in aspectScores) {
      if (a.aspect.toLowerCase().contains(lower)) {
        return (a.score * 100).round().clamp(0, 100);
      }
    }
    return null; // No fallback
  }

  // ─────────── Factores que más influyen (explicabilidad dinámica) ───────────
  static const Color _green = Color(0xFF2EA66B); // fortaleza
  static const Color _amber = Color(0xFFE8920C); // oportunidad
  static const Color _red = Color(0xFFE0563F);   // a tener en cuenta

  /// (icono, frase fuerte, frase débil) por aspecto.
  static const Map<String, (IconData, String, String)> _aspMeta = {
    'atractivos':   (Icons.photo_camera_rounded, 'Atractivos imperdibles', 'Atractivos algo limitados'),
    'seguridad':    (Icons.shield_rounded, 'Destino seguro', 'Cuida tu seguridad'),
    'limpieza':     (Icons.cleaning_services_rounded, 'Limpio y bien cuidado', 'Limpieza mejorable'),
    'gastronomia':  (Icons.restaurant_rounded, 'Buena gastronomía', 'Oferta gastronómica limitada'),
    'clima':        (Icons.wb_sunny_rounded, 'Clima ideal este mes', 'Clima poco favorable este mes'),
    'costos':       (Icons.payments_rounded, 'Buena relación precio', 'Puede salir algo caro'),
    'accesibilidad':(Icons.directions_walk_rounded, 'Fácil de llegar', 'Acceso algo complicado'),
    'atencion':     (Icons.support_agent_rounded, 'Buena atención', 'Atención irregular'),
    'alojamiento':  (Icons.hotel_rounded, 'Buen alojamiento', 'Pocas opciones de hospedaje'),
    'aforo':        (Icons.groups_rounded, 'Tranquilo, sin colas', 'Suele estar concurrido'),
  };

  static String _sinAcentos(String s) {
    s = s.toLowerCase().trim();
    const r = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'};
    r.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  static String _aspKey(String raw) {
    final s = _sinAcentos(raw);
    if (s.contains('atractivo')) return 'atractivos';
    if (s.contains('segur')) return 'seguridad';
    if (s.contains('limpie')) return 'limpieza';
    if (s.contains('gastron')) return 'gastronomia';
    if (s.contains('clima')) return 'clima';
    if (s.contains('costo') || s.contains('precio')) return 'costos';
    if (s.contains('acces')) return 'accesibilidad';
    if (s.contains('atenci') || s.contains('servicio')) return 'atencion';
    if (s.contains('aloja')) return 'alojamiento';
    if (s.contains('aforo') || s.contains('multitud')) return 'aforo';
    return s;
  }

  InfluenceFactorItem? _factor(AspectScoreModel a, {required bool strong}) {
    final meta = _aspMeta[_aspKey(a.aspect)];
    if (meta == null) return null;
    final pct = (a.score * 100).round();
    final color = a.score >= 0.70 ? _green : (a.score >= 0.50 ? _amber : _red);
    return InfluenceFactorItem(
      icon: meta.$1,
      title: strong ? meta.$2 : meta.$3,
      description: strong ? 'De lo mejor de este destino · $pct%' : 'A tener en cuenta · $pct%',
      color: color,
    );
  }

  /// Factor extra que conecta el destino con los intereses del viajero.
  InfluenceFactorItem? _factorPerfil(List<AspectScoreModel> items) {
    final prof = travelerProfile;
    if (prof == null || prof.intereses.isEmpty) return null;
    const map = {
      'cultura': 'atractivos', 'naturaleza': 'atractivos', 'aventura': 'atractivos',
      'fotografia': 'atractivos', 'gastronomia': 'gastronomia', 'relax': 'limpieza',
      'relajacion': 'limpieza',
    };
    for (final raw in prof.intereses) {
      final interes = _sinAcentos(raw);
      final aspKey = map[interes];
      if (aspKey == null) continue;
      for (final a in items) {
        if (_aspKey(a.aspect) == aspKey && a.score >= 0.6) {
          final nombre = interes.isEmpty ? interes : '${interes[0].toUpperCase()}${interes.substring(1)}';
          return InfluenceFactorItem(
            icon: Icons.favorite_rounded,
            title: 'Encaja con tu gusto por $nombre',
            description: 'Justo lo que buscas en este viaje',
            color: AppColors.accent,
          );
        }
      }
    }
    return null;
  }

  /// Construye, en vivo, los factores que explican el "por qué" del destino:
  /// 2 fortalezas, 1 coincidencia con tu perfil y 1-2 puntos a tener en cuenta.
  List<Widget> _buildInfluenceSection() {
    // Combina los 8 aspectos ABSA + clima/aforo del CONTEXTO real del mes,
    // para que los factores reflejen también la temporada elegida.
    final items = <AspectScoreModel>[
      ...aspectScores,
      if (climaContextScore != null) AspectScoreModel(aspect: 'Clima', score: climaContextScore!),
      if (aforoContextScore != null) AspectScoreModel(aspect: 'Aforo', score: aforoContextScore!),
    ];
    if (items.isEmpty) return [];
    items.sort((a, b) => b.score.compareTo(a.score));

    final factores = <InfluenceFactorItem>[];
    for (final a in items.where((a) => a.score >= 0.65).take(2)) {
      final f = _factor(a, strong: true);
      if (f != null) factores.add(f);
    }
    final perfil = _factorPerfil(items);
    if (perfil != null) factores.add(perfil);
    for (final a in items.reversed.where((a) => a.score < 0.50).take(2)) {
      final f = _factor(a, strong: false);
      if (f != null) factores.add(f);
    }
    if (factores.isEmpty) return [];

    final children = <Widget>[];
    for (var i = 0; i < factores.length; i++) {
      children.add(factores[i]);
      if (i < factores.length - 1) children.add(const SizedBox(height: 14));
    }
    return [
      _buildSectionTitle('Factores que más influyen'),
      const SizedBox(height: 14),
      ...children,
    ];
  }
}
