/// Ошибка авторизации с понятным пользователю текстом.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Переводит код ошибки Firebase Auth в сообщение на русском языке.
///
/// Новые проекты Firebase по умолчанию включают защиту от перебора email,
/// поэтому при неверном email или пароле приходит общий код
/// `invalid-credential` вместо `user-not-found` / `wrong-password`.
String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Некорректный формат email.';
    case 'email-already-in-use':
      return 'Этот email уже зарегистрирован. Попробуйте войти.';
    case 'weak-password':
      return 'Слишком простой пароль. Используйте не меньше 6 символов.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'Неверный email или пароль.';
    case 'missing-password':
      return 'Введите пароль.';
    case 'user-disabled':
      return 'Этот аккаунт заблокирован.';
    case 'too-many-requests':
      return 'Слишком много попыток. Подождите немного и повторите.';
    case 'network-request-failed':
      return 'Нет подключения к интернету.';
    case 'operation-not-allowed':
      return 'Вход по email и паролю отключён в настройках Firebase.';
    default:
      return 'Не удалось выполнить операцию. Попробуйте ещё раз.';
  }
}
