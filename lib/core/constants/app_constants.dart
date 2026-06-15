/// Constantes de dominio compartidas en toda la app PROXVEL.
///
/// Centraliza valores que antes estaban duplicados como "números mágicos"
/// (umbrales de compatibilidad) en vistas y controllers.
class AppConstants {
  AppConstants._();

  /// Compatibilidad (%) a partir de la cual un destino se etiqueta como
  /// "Recomendado" / color de éxito.
  static const int compatibilityRecommended = 85;

  /// Compatibilidad (%) a partir de la cual un destino es "Parcial".
  /// Por debajo de este valor se considera "Normal" / "Por explorar".
  static const int compatibilityPartial = 70;
}
