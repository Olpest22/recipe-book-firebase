import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/services/auth_errors.dart';

void main() {
  test('ошибки неверных данных дают одно понятное сообщение', () {
    const expected = 'Неверный email или пароль.';
    expect(authErrorMessage('invalid-credential'), expected);
    expect(authErrorMessage('wrong-password'), expected);
    expect(authErrorMessage('user-not-found'), expected);
  });

  test('занятый email и неизвестная ошибка', () {
    expect(authErrorMessage('email-already-in-use'), contains('уже зарегистрирован'));
    expect(authErrorMessage('some-unknown-code'), isNotEmpty);
  });
}
