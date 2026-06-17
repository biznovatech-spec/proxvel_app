import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../integration/services/announcement_service.dart';

/// Controla los anuncios internos visibles en la app.
/// El usuario puede descartar el anuncio actual en sesión (no persiste).
///
/// Es multi-placement: cada ubicación (p. ej. 'home_top' para el banner,
/// 'app_start' para el modal de inicio) se carga y cachea por separado.
class AnnouncementController extends ChangeNotifier {
  final AnnouncementService _service;
  AnnouncementController(this._service);

  final Map<String, List<AnnouncementModel>> _byPlacement = {};
  final Set<int> _dismissed = <int>{};
  final Set<String> _loadedPlacements = <String>{};

  /// Anuncio de mayor prioridad no descartado para un placement dado, o null.
  AnnouncementModel? currentFor(String placement) {
    for (final a in _byPlacement[placement] ?? const <AnnouncementModel>[]) {
      if (!_dismissed.contains(a.id)) return a;
    }
    return null;
  }

  /// Atajo del banner del home (placement 'home_top').
  AnnouncementModel? get current => currentFor('home_top');

  bool get hasAnnouncement => current != null;

  Future<void> load({String placement = 'home_top'}) async {
    // Evita recargas innecesarias en cada rebuild.
    if (_loadedPlacements.contains(placement)) return;
    _loadedPlacements.add(placement);
    _byPlacement[placement] = await _service.getActive(placement: placement);
    notifyListeners();
  }

  void dismiss(int id) {
    _dismissed.add(id);
    notifyListeners();
  }

  /// Fuerza una recarga de un placement (p. ej. pull-to-refresh).
  Future<void> refresh({String placement = 'home_top'}) async {
    _loadedPlacements.remove(placement);
    await load(placement: placement);
  }
}
