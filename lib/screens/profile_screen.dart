import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_scope.dart';
import '../utils/auth_navigation.dart';
import '../utils/validators.dart';

/// Профиль: для гостя — объяснение ограничений и кнопки входа,
/// для авторизованного пользователя — данные аккаунта и выход.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([scope.authService, scope.favoritesService]),
      builder: (context, _) {
        final user = scope.authService.currentUser;
        return Scaffold(
          appBar: AppBar(title: Text(user == null ? 'Аккаунт' : 'Профиль')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: user == null
                    ? const _GuestProfile()
                    : _UserProfile(
                        user: user,
                        favoritesCount:
                            scope.favoritesService.favoriteIds.length,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(Icons.person_outline,
              size: 44, color: theme.colorScheme.onSecondaryContainer),
        ),
        const SizedBox(height: 16),
        Text('Вы в гостевом режиме',
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Часть функций доступна только после входа в аккаунт.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _FeatureAccessRow('Каталог и поиск рецептов', isAvailable: true),
                _FeatureAccessRow('Списки ингредиентов', isAvailable: true),
                _FeatureAccessRow('Пошаговые инструкции', isAvailable: false),
                _FeatureAccessRow('Избранные рецепты', isAvailable: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => openSignIn(context),
          icon: const Icon(Icons.login),
          label: const Text('Войти'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => openSignUp(context),
          child: const Text('Создать аккаунт'),
        ),
      ],
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.user, required this.favoritesCount});

  final User user;
  final int favoritesCount;

  String get _displayName {
    final name = user.displayName?.trim() ?? '';
    return name.isEmpty ? 'Пользователь' : name;
  }

  /// Выход с подтверждением. После выхода приложение остаётся открытым
  /// в гостевом режиме: закрытые функции снова блокируются.
  Future<void> _confirmSignOut(BuildContext context) async {
    final authService = AppScope.of(context).authService;
    final messenger = ScaffoldMessenger.of(context);

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Пошаговые рецепты и избранное станут недоступны до следующего входа.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (isConfirmed != true) return;

    await authService.signOut();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Вы вышли из аккаунта. Включён гостевой режим.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = user.metadata.creationTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            _displayName[0].toUpperCase(),
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text(_displayName,
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            avatar: const Icon(Icons.verified_outlined, size: 18),
            label: const Text('Все функции доступны'),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email ?? '—'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Аккаунт создан'),
                subtitle: Text(createdAt == null ? '—' : formatDate(createdAt)),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Рецептов в избранном'),
                subtitle: Text('$favoritesCount'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Выйти из аккаунта'),
        ),
      ],
    );
  }
}

/// Строка «функция — доступна / требует входа».
class _FeatureAccessRow extends StatelessWidget {
  const _FeatureAccessRow(this.title, {required this.isAvailable});

  final String title;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
        isAvailable ? Icons.check_circle_outline : Icons.lock_outline,
        color: isAvailable ? colors.primary : colors.outline,
      ),
      title: Text(title),
      trailing: Text(
        isAvailable ? 'Доступно' : 'После входа',
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
    );
  }
}
