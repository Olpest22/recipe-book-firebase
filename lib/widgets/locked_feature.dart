import 'package:flutter/material.dart';

import '../utils/auth_navigation.dart';

/// Заглушка вместо функции, доступной только после входа.
/// [compact] — вариант-карточка для встраивания внутрь экрана,
/// иначе — блок по центру во весь экран.
class LockedFeature extends StatelessWidget {
  const LockedFeature({
    super.key,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: compact ? 24 : 40,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.lock_outline,
            size: compact ? 24 : 40,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: compact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => openSignIn(context),
              icon: const Icon(Icons.login),
              label: const Text('Войти'),
            ),
            OutlinedButton(
              onPressed: () => openSignUp(context),
              child: const Text('Создать аккаунт'),
            ),
          ],
        ),
      ],
    );

    if (compact) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(padding: const EdgeInsets.all(24), child: content),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: content,
        ),
      ),
    );
  }
}
