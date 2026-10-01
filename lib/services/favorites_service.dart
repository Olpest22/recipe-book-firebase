import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

/// Избранные рецепты. Функция доступна только авторизованным пользователям.
///
/// Список хранится локально отдельно для каждого аккаунта (ключ содержит uid),
/// поэтому после смены пользователя показывается его собственное избранное.
class FavoritesService extends ChangeNotifier {
  FavoritesService({
    required AuthService authService,
    required SharedPreferences preferences,
  })  : _authService = authService,
        _preferences = preferences {
    _authService.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final AuthService _authService;
  final SharedPreferences _preferences;

  Set<String> _favoriteIds = <String>{};
  String? _loadedForUserId;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  /// Добавляет рецепт в избранное или убирает его.
  /// Для гостя ничего не делает: проверка доступа выполняется в интерфейсе.
  Future<void> toggle(String recipeId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    if (!_favoriteIds.remove(recipeId)) {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();
    await _preferences.setStringList(_storageKey(userId), _favoriteIds.toList());
  }

  /// При входе загружает избранное пользователя, при выходе очищает его.
  void _handleAuthChanged() {
    final userId = _authService.currentUser?.uid;
    if (userId == _loadedForUserId) return;

    _loadedForUserId = userId;
    _favoriteIds = userId == null
        ? <String>{}
        : (_preferences.getStringList(_storageKey(userId)) ?? []).toSet();
    notifyListeners();
  }

  static String _storageKey(String userId) => 'favorites_$userId';

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChanged);
    super.dispose();
  }
}
