class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    if (!value.contains('@')) return 'Correo inválido';
    return null;
  }
}
