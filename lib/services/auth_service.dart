import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_errors.dart';

export 'auth_errors.dart' show AuthFailure;

/// Обёртка над Firebase Authentication.
///
/// Экраны не работают с FirebaseAuth напрямую: они вызывают методы сервиса
/// и подписываются на его изменения (ChangeNotifier). Ошибки Firebase
/// превращаются в [AuthFailure] с понятным текстом.
class AuthService extends ChangeNotifier {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required SharedPreferences preferences,
  })  : _firebaseAuth = firebaseAuth,
        _preferences = preferences,
        _currentUser = firebaseAuth.currentUser {
    // userChanges() срабатывает при входе, выходе и изменении профиля
    // (например, имени), поэтому интерфейс всегда показывает актуальные данные.
    _userSubscription = _firebaseAuth.userChanges().listen(_handleUserChanged);
  }

  /// Ключ, под которым хранится email последнего входа (для автозаполнения).
  static const _lastEmailKey = 'last_signed_in_email';

  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _preferences;
  late final StreamSubscription<User?> _userSubscription;
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  /// Email, с которым пользователь входил в прошлый раз.
  String get lastEmail => _preferences.getString(_lastEmailKey) ?? '';

  /// Регистрация нового пользователя по email и паролю.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
    });
    await _rememberEmail(email);
  }

  /// Вход по email и паролю.
  Future<void> signIn({required String email, required String password}) async {
    await _runAuthAction(
      () => _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
    await _rememberEmail(email);
  }

  /// Отправляет письмо для сброса пароля.
  Future<void> sendPasswordReset(String email) {
    return _runAuthAction(
      () => _firebaseAuth.sendPasswordResetEmail(email: email.trim()),
    );
  }

  /// Выход из аккаунта. Firebase удаляет сохранённую сессию,
  /// а userChanges() передаёт null, и приложение переходит в гостевой режим.
  Future<void> signOut() => _firebaseAuth.signOut();

  void _handleUserChanged(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> _rememberEmail(String email) {
    return _preferences.setString(_lastEmailKey, email.trim());
  }

  /// Выполняет действие Firebase и переводит его ошибки в [AuthFailure].
  Future<T> _runAuthAction<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authErrorMessage(error.code));
    }
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }
}
