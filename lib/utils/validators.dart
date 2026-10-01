/// Проверка полей форм регистрации и входа.
/// Каждый метод возвращает текст ошибки или null, если значение корректно.
class Validators {
  Validators._();

  static const minPasswordLength = 6;

  static final _emailPattern =
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[A-Za-z]{2,}$');
  static final _letterPattern = RegExp(r'[A-Za-zА-Яа-яЁё]');
  static final _digitPattern = RegExp(r'\d');

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введите имя';
    if (trimmed.length < 2) return 'Имя слишком короткое';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Введите email';
    if (!_emailPattern.hasMatch(trimmed)) return 'Некорректный формат email';
    return null;
  }

  /// Для входа достаточно, чтобы пароль был введён.
  static String? enteredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    return null;
  }

  /// Для регистрации пароль должен быть надёжнее
  /// (Firebase сам требует минимум 6 символов).
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < minPasswordLength) {
      return 'Минимум $minPasswordLength символов';
    }
    if (!_letterPattern.hasMatch(value) || !_digitPattern.hasMatch(value)) {
      return 'Пароль должен содержать буквы и цифры';
    }
    return null;
  }

  /// Возвращает валидатор, сравнивающий значение с исходным паролем.
  static String? Function(String?) confirmPassword(
    String Function() originalPassword,
  ) {
    return (value) =>
        value != originalPassword() ? 'Пароли не совпадают' : null;
  }
}

/// Форматирует дату в вид «01.10.2026».
String formatDate(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}';
}
