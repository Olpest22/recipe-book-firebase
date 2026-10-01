import 'package:flutter/material.dart';

import '../utils/app_scope.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Корневой экран с навигацией между разделами.
///
/// Адаптивность: на узких экранах (телефон) — нижняя панель NavigationBar,
/// на широких (планшет, альбомная ориентация) — боковая NavigationRail.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _railBreakpoint = 640.0;
  static const _extendedRailBreakpoint = 1000.0;

  int _selectedIndex = 0;

  // IndexedStack сохраняет состояние вкладок (например, текст поиска).
  static const _pages = [CatalogScreen(), FavoritesScreen(), ProfileScreen()];

  void _selectPage(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final authService = AppScope.of(context).authService;

    return ListenableBuilder(
      listenable: authService,
      builder: (context, _) {
        final isGuest = !authService.isSignedIn;
        final destinations = [
          _Destination(Icons.menu_book_outlined, Icons.menu_book, 'Рецепты'),
          _Destination(Icons.favorite_border, Icons.favorite, 'Избранное',
              isLocked: isGuest),
          _Destination(Icons.person_outline, Icons.person,
              isGuest ? 'Войти' : 'Профиль'),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final body = IndexedStack(index: _selectedIndex, children: _pages);

            if (constraints.maxWidth < _railBreakpoint) {
              return Scaffold(
                body: body,
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectPage,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: destination.buildIcon(context, selected: false),
                        selectedIcon:
                            destination.buildIcon(context, selected: true),
                        label: destination.label,
                      ),
                  ],
                ),
              );
            }

            final isExtended = constraints.maxWidth >= _extendedRailBreakpoint;
            return Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    right: false,
                    child: NavigationRail(
                      extended: isExtended,
                      labelType: isExtended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _selectPage,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon:
                                destination.buildIcon(context, selected: false),
                            selectedIcon:
                                destination.buildIcon(context, selected: true),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: body),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Описание пункта навигации. Закрытые для гостя разделы
/// помечаются значком замка.
class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label,
      {this.isLocked = false});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isLocked;

  Widget buildIcon(BuildContext context, {required bool selected}) {
    final iconWidget = Icon(selected ? selectedIcon : icon);
    if (!isLocked) return iconWidget;

    return Badge(
      label: Icon(
        Icons.lock,
        size: 10,
        color: Theme.of(context).colorScheme.onError,
      ),
      child: iconWidget,
    );
  }
}
