import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../integration/services/peru_location_service.dart';

class ResidenceFieldsWidget extends StatefulWidget {
  final String? initialDepartment;
  final String? initialProvince;
  final String? initialCity;
  final void Function(String? department, String? province, String? city) onChanged;

  const ResidenceFieldsWidget({
    super.key,
    this.initialDepartment,
    this.initialProvince,
    this.initialCity,
    required this.onChanged,
  });

  @override
  State<ResidenceFieldsWidget> createState() => _ResidenceFieldsWidgetState();
}

class _ResidenceFieldsWidgetState extends State<ResidenceFieldsWidget> {
  String? _selectedDepartment;
  String? _selectedProvince;
  String? _selectedCity;

  List<String> _departments = [];
  List<String> _provinces = [];
  List<String> _cities = [];
  bool _isLocationsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocations(widget.initialDepartment, widget.initialProvince, widget.initialCity);
  }

  Future<void> _loadLocations(String? dept, String? prov, String? city) async {
    final service = PeruLocationService();
    await service.init();
    
    if (mounted) {
      setState(() {
        _departments = service.getDepartments();
        _isLocationsLoaded = true;
        
        if (dept != null && _departments.contains(dept)) {
          _selectedDepartment = dept;
          _provinces = service.getProvinces(dept);
          
          if (prov != null && _provinces.contains(prov)) {
            _selectedProvince = prov;
            _cities = service.getDistricts(dept, prov);
            
            if (city != null && _cities.contains(city)) {
              _selectedCity = city;
            }
          }
        }
      });
      // Fire initial callback if values were prefilled
      widget.onChanged(_selectedDepartment, _selectedProvince, _selectedCity);
    }
  }

  void _onDepartmentChanged(String? value) {
    setState(() {
      _selectedDepartment = value;
      _selectedProvince = null;
      _selectedCity = null;
      _provinces = value != null ? PeruLocationService().getProvinces(value) : [];
      _cities = [];
    });
    widget.onChanged(_selectedDepartment, _selectedProvince, _selectedCity);
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedCity = null;
      _cities = value != null && _selectedDepartment != null 
          ? PeruLocationService().getDistricts(_selectedDepartment!, value) 
          : [];
    });
    widget.onChanged(_selectedDepartment, _selectedProvince, _selectedCity);
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
    });
    widget.onChanged(_selectedDepartment, _selectedProvince, _selectedCity);
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              items: items.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              )).toList(),
              onChanged: enabled ? onChanged : null,
              hint: Text('Seleccionar $label', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocationsLoaded) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown(
          label: 'Departamento',
          value: _selectedDepartment,
          items: _departments,
          onChanged: _onDepartmentChanged,
          enabled: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Provincia',
          value: _selectedProvince,
          items: _provinces,
          onChanged: _onProvinceChanged,
          enabled: _selectedDepartment != null,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Ciudad / Distrito',
          value: _selectedCity,
          items: _cities,
          onChanged: _onCityChanged,
          enabled: _selectedProvince != null,
        ),
      ],
    );
  }
}
