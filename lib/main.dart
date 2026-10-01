import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase нужно инициализировать до первого обращения к FirebaseAuth.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();

  // Сессию Firebase Auth сохраняет сам: после перезапуска приложения
  // пользователь остаётся авторизованным, пока не нажмёт «Выйти».
  final authService = AuthService(
    firebaseAuth: FirebaseAuth.instance,
    preferences: preferences,
  );
  final favoritesService = FavoritesService(
    authService: authService,
    preferences: preferences,
  );

  runApp(RecipeBookApp(
    authService: authService,
    favoritesService: favoritesService,
  ));
}
