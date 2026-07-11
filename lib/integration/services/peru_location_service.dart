import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/peru_location_model.dart';

class PeruLocationService {
  static final PeruLocationService _instance = PeruLocationService._internal();
  factory PeruLocationService() => _instance;
  PeruLocationService._internal();

  List<PeruLocationModel> _locations = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final String jsonString = await rootBundle.loadString('assets/data/peru_locations.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _locations = jsonList
          .map((e) => PeruLocationModel.fromJson(e))
          .where((m) => m.ubigeo.isNotEmpty && m.department.isNotEmpty && m.province.isNotEmpty && m.district.isNotEmpty)
          .toList();
      _isInitialized = true;
    } catch (e) {
      // Manejar error silenciosamente según requerimientos, pero imprimir en consola local para debug
      _locations = [];
    }
  }

  List<String> getDepartments() {
    return _locations.map((e) => e.department).toSet().toList()..sort();
  }

  List<String> getProvinces(String department) {
    return _locations
        .where((e) => e.department == department)
        .map((e) => e.province)
        .toSet()
        .toList()..sort();
  }

  List<String> getDistricts(String department, String province) {
    return _locations
        .where((e) => e.department == department && e.province == province)
        .map((e) => e.district)
        .toSet()
        .toList()..sort();
  }

  PeruLocationModel? findBySelection(String department, String province, String district) {
    try {
      return _locations.firstWhere((e) =>
          e.department == department &&
          e.province == province &&
          e.district == district);
    } catch (_) {
      return null;
    }
  }
}
