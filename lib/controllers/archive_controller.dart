import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/archive_model.dart';
import '../models/destination_model.dart';
import '../integration/services/archive_service.dart';

/// Archivados LOCAL-first (persistido en el dispositivo). Un destino archivado
/// deja de aparecer en Explorar y en "Para Ti"; solo se puede desarchivar desde
/// la pantalla de Archivados (Perfil → Archivados). Backend best-effort.
class ArchiveController extends ChangeNotifier {
  final ArchiveService _archiveService;
  static const _prefsKey = 'local_archives_v1';

  bool isLoading = false;
  List<ArchiveModel> archives = [];
  Set<String> archivedDestinationIds = {};
  String? error;

  ArchiveController(this._archiveService);

  Future<void> loadArchives() async {
    isLoading = true;
    error = null;
    notifyListeners();
    await _loadLocal();
    isLoading = false;
    notifyListeners();
  }

  /// Archiva/desarchiva. Pasa el `model` al ARCHIVAR para guardar sus datos.
  Future<void> toggleArchive(String id, [DestinationModel? model]) async {
    final isArc = isArchived(id);
    if (isArc) {
      archivedDestinationIds.remove(id);
      archives.removeWhere((a) => a.destinationId == id);
    } else {
      archivedDestinationIds.add(id);
      if (model != null && !archives.any((a) => a.destinationId == id)) {
        archives.add(ArchiveModel(
          destinationId: model.id,
          name: model.name,
          city: model.city,
          region: model.region,
          category: model.category,
          coverImageUrl: model.imageUrl,
          createdAt: DateTime.now(),
        ));
      }
    }
    notifyListeners();
    await _saveLocal();

    try {
      if (isArc) {
        await _archiveService.removeArchive(id);
      } else {
        await _archiveService.addArchive(id);
      }
    } catch (_) {}
  }

  bool isArchived(String id) => archivedDestinationIds.contains(id);

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((e) => ArchiveModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        archives = list;
        archivedDestinationIds = list.map((a) => a.destinationId).toSet();
      }
    } catch (_) {}
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(archives.map((a) => a.toJson()).toList()),
      );
    } catch (_) {}
  }
}
