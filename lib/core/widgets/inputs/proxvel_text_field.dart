import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProxvelTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool isPassword;
  final Function(String)? onChanged;
  final String? errorText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final String? helperText;
  final Widget? prefixIcon;
  final Color? fillColor;

  const ProxvelTextField({
    super.key,
    required this.label,
    this.controller,
    this.isPassword = false,
    this.onChanged,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.readOnly = false,
    this.helperText,
    this.prefixIcon,
    this.fillColor,
  });

  @override
  State<ProxvelTextField> createState() => _ProxvelTextFieldState();
}

class _ProxvelTextFieldState extends State<ProxvelTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.errorText != null ? 8 : 16),
      child: TextField(
        controller: widget.controller,
        readOnly: widget.readOnly,
        obscureText: widget.isPassword ? _obscureText : false,
        onChanged: widget.onChanged,
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: widget.errorText != null ? Colors.red : const Color(0xFF9CA3AF)), // Gray-400 or Red
          errorText: widget.errorText,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon,
          filled: true,
          fillColor: widget.fillColor ?? Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.errorText != null ? Colors.red : const Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.errorText != null ? Colors.red : const Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.errorText != null ? Colors.red : const Color(0xFF374151)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
