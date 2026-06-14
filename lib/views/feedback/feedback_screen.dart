import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/feedback_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/feedback_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/rating_selector.dart';
import 'widgets/feedback_option_chip.dart';

class FeedbackScreen extends StatefulWidget {
  final String destinationId;
  const FeedbackScreen({super.key, required this.destinationId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  String _selectedType = '';
  final _commentController = TextEditingController();
  bool _submitted = false;

  static const _experienceTypes = [
    {'label': 'Visita', 'icon': Icons.location_on_outlined},
    {'label': 'Alojamiento', 'icon': Icons.hotel_outlined},
    {'label': 'Gastronomía', 'icon': Icons.restaurant_outlined},
    {'label': 'Aventura', 'icon': Icons.hiking_rounded},
    {'label': 'Cultural', 'icon': Icons.museum_outlined},
    {'label': 'Familiar', 'icon': Icons.family_restroom_rounded},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final fbCtrl = context.watch<FeedbackController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _submitted
                ? _buildSuccessState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ═══ RATING ═══
                        _sectionTitle('¿Cómo fue tu experiencia?'),
                        const SizedBox(height: 16),
                        RatingSelector(
                          rating: _rating,
                          onChanged: (v) => setState(() => _rating = v),
                        ),

                        const SizedBox(height: 32),

                        // ═══ EXPERIENCE TYPE ═══
                        _sectionTitle('Tipo de experiencia'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _experienceTypes.map((t) {
                            final label = t['label'] as String;
                            final icon = t['icon'] as IconData;
                            return FeedbackOptionChip(
                              label: label,
                              icon: icon,
                              isSelected: _selectedType == label,
                              onTap: () =>
                                  setState(() => _selectedType = label),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // ═══ COMMENT ═══
                        _sectionTitle('Comentario breve'),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.border, width: 1),
                          ),
                          child: TextField(
                            controller: _commentController,
                            onChanged: (_) => setState(() {}),
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText:
                                  'Escribe un comentario breve para enviar tu reseña...',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ═══ SUBMIT BUTTON ═══
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: GestureDetector(
                            onTap: _canSubmit && !fbCtrl.isSubmitting
                                ? _submit
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _canSubmit
                                    ? AppColors.primary
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: _canSubmit
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: fbCtrl.isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Enviar feedback',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _canSubmit
                                            ? Colors.white
                                            : AppColors.textMuted,
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
    );
  }

  bool get _canSubmit =>
      _rating > 0 &&
      _selectedType.isNotEmpty &&
      _commentController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final currentUser = context.read<AuthController>().currentUser;
    
    if (currentUser == null || !currentUser.id.startsWith('U000')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un usuario activo. Regístrate o inicia sesión para continuar.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final userId = currentUser.id;

    final feedback = FeedbackModel(
      userId: userId,
      destinationId: widget.destinationId,
      rating: _rating,
      comment: _commentController.text.trim(),
      interactionType: _selectedType,
    );

    final success =
        await context.read<FeedbackController>().submitFeedback(feedback);
    
    if (mounted) {
      if (success) {
        setState(() => _submitted = true);
      } else {
        final errorMsg = context.read<FeedbackController>().error ?? '';
        String displayMsg = 'No se pudo enviar la reseña. Inténtalo nuevamente.';
        
        if (errorMsg.contains('Usuario no existe')) {
          displayMsg = 'Tu usuario no está sincronizado con el servidor. Inicia con un usuario demo e inténtalo nuevamente.';
        } else {
          displayMsg = 'No se pudo enviar la reseña. Usuario no válido o sesión no sincronizada.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

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
          padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calificar experiencia',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tu opinión mejora las recomendaciones',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textOnDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rate_review_rounded,
                    color: AppColors.accent, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 50),
            ),
            const SizedBox(height: 28),
            const Text(
              '¡Gracias por tu feedback!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu opinión ayuda a mejorar las\nrecomendaciones para todos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Volver al destino',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
