/// Anuncio interno publicado desde el dashboard admin.
/// Mapea la vista pública del backend (GET /announcements/active),
/// que NO expone campos internos (audience, frequency_cap, fechas, etc.).
class AnnouncementModel {
  final int id;
  final String title;
  final String message;
  final String placement;
  final String templateType;
  final String? backgroundImageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final int durationSeconds;
  final int priority;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.placement,
    required this.templateType,
    this.backgroundImageUrl,
    this.ctaText,
    this.ctaUrl,
    this.durationSeconds = 5,
    this.priority = 0,
  });

  factory AnnouncementModel.fromApiJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      placement: (json['placement'] ?? 'home_top') as String,
      templateType: (json['template_type'] ?? 'gradient_card') as String,
      backgroundImageUrl: json['background_image_url'] as String?,
      ctaText: json['cta_text'] as String?,
      ctaUrl: json['cta_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 5,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
    );
  }

  /// Un anuncio solo es presentable si tiene contenido textual real.
  bool get hasContent => title.trim().isNotEmpty && message.trim().isNotEmpty;
}
