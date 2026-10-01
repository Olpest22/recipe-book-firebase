import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import 'app_scope.dart';

/// Экраны входа и регистрации открываются поверх текущего экрана:
/// приложением можно пользоваться и без авторизации, поэтому после
/// входа пользователь возвращается туда, где был.
Future<void> openSignIn(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SignInScreen()),
  );
}

Future<void> openSignUp(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SignUpScreen()),
  );
}

/// Объясняет гостю, что функция требует входа, и предлагает войти.
Future<void> showAuthRequiredDialog(
  BuildContext context, {
  required String featureName,
}) async {
  final shouldSignIn = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.lock_outline),
      title: const Text('Нужен аккаунт'),
      content: Text(
        '$featureName доступно только авторизованным пользователям. '
        'Войдите или зарегистрируйтесь — это займёт минуту.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Не сейчас'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Войти'),
        ),
      ],
    ),
  );

  if (shouldSignIn == true && context.mounted) {
    await openSignIn(context);
  }
}

/// Нажатие на «сердечко»: авторизованный пользователь меняет избранное,
/// гость видит предложение войти.
Future<void> toggleFavoriteOrAskToSignIn(
  BuildContext context,
  Recipe recipe,
) async {
  final scope = AppScope.of(context);
  if (!scope.authService.isSignedIn) {
    await showAuthRequiredDialog(context, featureName: 'Добавление в избранное');
    return;
  }
  await scope.favoritesService.toggle(recipe.id);
}
