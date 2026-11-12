/// Validações reutilizadas nos formulários (retornam a mensagem de erro ou null).
class Validators {
  Validators._();

  static String? requiredText(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? email(String? value) {
    final empty = requiredText(value, 'Introduza o email');
    if (empty != null) return empty;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value!.trim()) ? null : 'Introduza um email válido';
  }

  static String? password(String? value) {
    final empty = requiredText(value, 'Introduza a palavra-passe');
    if (empty != null) return empty;
    return value!.length < 6
        ? 'A palavra-passe deve ter pelo menos 6 caracteres'
        : null;
  }

  static String? petName(String? value) {
    final empty = requiredText(value, 'O nome não pode estar vazio');
    if (empty != null) return empty;
    return value!.trim().length > 40
        ? 'O nome deve ter no máximo 40 caracteres'
        : null;
  }

  static String? breed(String? value) {
    return requiredText(value, 'Introduza a raça');
  }

  static String? age(String? value) {
    final empty = requiredText(value, 'Introduza a idade');
    if (empty != null) return empty;
    final age = int.tryParse(value!.trim());
    if (age == null) return 'A idade deve ser um número inteiro';
    if (age < 0 || age > 40) return 'A idade deve estar entre 0 e 40 anos';
    return null;
  }

  static String? weight(String? value) {
    final empty = requiredText(value, 'Introduza o peso');
    if (empty != null) return empty;
    final weight = parseDecimal(value!);
    if (weight == null || weight.isNaN || weight.isInfinite) {
      return 'Introduza um número válido';
    }
    if (weight <= 0) return 'O peso deve ser um número positivo';
    if (weight > 150) return 'Peso demasiado elevado (máximo 150 kg)';
    return null;
  }

  static String? reminderTitle(String? value) {
    return requiredText(value, 'Introduza um título para o lembrete');
  }

  /// Aceita vírgula ou ponto decimal ("4,5" ou "4.5").
  static double? parseDecimal(String text) {
    return double.tryParse(text.trim().replaceAll(',', '.'));
  }
}
