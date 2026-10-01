import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/favorites_service.dart';
import 'utils/app_scope.dart';

class RecipeBookApp extends StatelessWidget {
  const RecipeBookApp({
    super.key,
    required this.authService,
    required this.favoritesService,
  });

  final AuthService authService;
  final FavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    // AppScope стоит над MaterialApp, поэтому сервисы доступны
    // на любом экране, в том числе открытом через Navigator.push.
    return AppScope(
      authService: authService,
      favoritesService: favoritesService,
      child: MaterialApp(
        title: 'Книга рецептов',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const MainShell(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const buttonMinimumSize = Size(64, 48);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: brightness,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonMinimumSize),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonMinimumSize),
      ),
    );
  }
}
