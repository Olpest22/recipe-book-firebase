import 'package:flutter/widgets.dart';

import '../services/auth_service.dart';
import '../services/favorites_service.dart';

/// Передаёт сервисы вниз по дереву виджетов без сторонних пакетов.
/// Использование: `AppScope.of(context).authService`.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.authService,
    required this.favoritesService,
    required super.child,
  });

  final AuthService authService;
  final FavoritesService favoritesService;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден в дереве виджетов');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      authService != oldWidget.authService ||
      favoritesService != oldWidget.favoritesService;
}
