import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('принимает корректный email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('отклоняет пустой и некорректный email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('user@'), isNotNull);
      expect(Validators.email('user.example.com'), isNotNull);
    });
  });

  group('Validators.newPassword', () {
    test('требует минимум 6 символов', () {
      expect(Validators.newPassword('a1b2'), isNotNull);
    });

    test('требует буквы и цифры', () {
      expect(Validators.newPassword('abcdefgh'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('pass1234'), isNull);
    });
  });

  test('confirmPassword сравнивает с исходным паролем', () {
    final validator = Validators.confirmPassword(() => 'pass1234');
    expect(validator('pass1234'), isNull);
    expect(validator('other123'), isNotNull);
  });
}
