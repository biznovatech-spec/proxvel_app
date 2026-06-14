class TravelerProfileModel {
  final String presupuesto;
  final int diasViaje;
  final String climaPreferido;
  final String tipoInteres;
  final List<String> intereses;
  final String toleranciaMultitudes;

  // Pesos internos derivados (read-only for client)
  final double pesoAccesibilidad;
  final double pesoAforoMultitudes;
  final double pesoAlojamiento;
  final double pesoAtencionServicio;
  final double pesoAtractivos;
  final double pesoClima;
  final double pesoCostos;
  final double pesoGastronomia;
  final double pesoLimpieza;
  final double pesoSeguridad;

  TravelerProfileModel({
    required this.presupuesto,
    required this.diasViaje,
    required this.climaPreferido,
    required this.tipoInteres,
    required this.intereses,
    required this.toleranciaMultitudes,
    this.pesoAccesibilidad = 3.0,
    this.pesoAforoMultitudes = 3.0,
    this.pesoAlojamiento = 3.0,
    this.pesoAtencionServicio = 3.0,
    this.pesoAtractivos = 3.0,
    this.pesoClima = 3.0,
    this.pesoCostos = 3.0,
    this.pesoGastronomia = 3.0,
    this.pesoLimpieza = 3.0,
    this.pesoSeguridad = 3.0,
  });

  factory TravelerProfileModel.fromJson(Map<String, dynamic> json) => TravelerProfileModel(
        presupuesto: json['presupuesto'] ?? 'medio',
        diasViaje: json['dias_viaje'] ?? 3,
        climaPreferido: json['clima_preferido'] ?? 'templado',
        tipoInteres: json['tipo_interes'] ?? 'mixto',
        intereses: List<String>.from(json['intereses'] ?? []),
        toleranciaMultitudes: json['tolerancia_multitudes'] ?? 'moderado',
        pesoAccesibilidad: json['peso_accesibilidad']?.toDouble() ?? 3.0,
        pesoAforoMultitudes: json['peso_aforo_multitudes']?.toDouble() ?? 3.0,
        pesoAlojamiento: json['peso_alojamiento']?.toDouble() ?? 3.0,
        pesoAtencionServicio: json['peso_atencion_servicio']?.toDouble() ?? 3.0,
        pesoAtractivos: json['peso_atractivos']?.toDouble() ?? 3.0,
        pesoClima: json['peso_clima']?.toDouble() ?? 3.0,
        pesoCostos: json['peso_costos']?.toDouble() ?? 3.0,
        pesoGastronomia: json['peso_gastronomia']?.toDouble() ?? 3.0,
        pesoLimpieza: json['peso_limpieza']?.toDouble() ?? 3.0,
        pesoSeguridad: json['peso_seguridad']?.toDouble() ?? 3.0,
      );

  Map<String, dynamic> toJson() => {
        'presupuesto': presupuesto,
        'dias_viaje': diasViaje,
        'clima_preferido': climaPreferido,
        'tipo_interes': tipoInteres,
        'intereses': intereses,
        'tolerancia_multitudes': toleranciaMultitudes,
        'peso_accesibilidad': pesoAccesibilidad,
        'peso_aforo_multitudes': pesoAforoMultitudes,
        'peso_alojamiento': pesoAlojamiento,
        'peso_atencion_servicio': pesoAtencionServicio,
        'peso_atractivos': pesoAtractivos,
        'peso_clima': pesoClima,
        'peso_costos': pesoCostos,
        'peso_gastronomia': pesoGastronomia,
        'peso_limpieza': pesoLimpieza,
        'peso_seguridad': pesoSeguridad,
      };

  factory TravelerProfileModel.fromApiJson(Map<String, dynamic> json) => TravelerProfileModel(
        presupuesto: json['presupuesto'] ?? 'medio',
        diasViaje: json['dias_viaje'] ?? 3,
        climaPreferido: json['clima_preferido'] ?? 'templado',
        tipoInteres: json['tipo_interes'] ?? 'mixto',
        intereses: List<String>.from(json['intereses'] ?? []),
        toleranciaMultitudes: json['tolerancia_multitudes'] ?? 'moderado',
        pesoAccesibilidad: json['peso_accesibilidad']?.toDouble() ?? 3.0,
        pesoAforoMultitudes: json['peso_aforo_multitudes']?.toDouble() ?? 3.0,
        pesoAlojamiento: json['peso_alojamiento']?.toDouble() ?? 3.0,
        pesoAtencionServicio: json['peso_atencion_servicio']?.toDouble() ?? 3.0,
        pesoAtractivos: json['peso_atractivos']?.toDouble() ?? 3.0,
        pesoClima: json['peso_clima']?.toDouble() ?? 3.0,
        pesoCostos: json['peso_costos']?.toDouble() ?? 3.0,
        pesoGastronomia: json['peso_gastronomia']?.toDouble() ?? 3.0,
        pesoLimpieza: json['peso_limpieza']?.toDouble() ?? 3.0,
        pesoSeguridad: json['peso_seguridad']?.toDouble() ?? 3.0,
      );

  Map<String, dynamic> toApiJson() => {
        'presupuesto': presupuesto,
        'dias_viaje': diasViaje,
        'clima_preferido': climaPreferido,
        'tipo_interes': tipoInteres,
        'intereses': intereses,
        'tolerancia_multitudes': toleranciaMultitudes,
      };
}
