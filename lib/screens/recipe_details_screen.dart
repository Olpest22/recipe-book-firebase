import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../utils/app_scope.dart';
import '../utils/auth_navigation.dart';
import '../widgets/locked_feature.dart';
import '../widgets/recipe_card.dart';

/// Подробности рецепта. Ингредиенты видны всем,
/// пошаговые инструкции — только авторизованным пользователям.
class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key, required this.recipe});

  final Recipe recipe;

  /// Ширина, начиная с которой разделы выводятся в две колонки.
  static const _twoColumnBreakpoint = 840.0;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      // Если гость войдёт с этого экрана, шаги откроются сразу после возврата.
      listenable: Listenable.merge([scope.authService, scope.favoritesService]),
      builder: (context, _) {
        final isSignedIn = scope.authService.isSignedIn;
        final isFavorite = scope.favoritesService.isFavorite(recipe.id);

        final Widget stepsSection = isSignedIn
            ? _StepsSection(steps: recipe.steps)
            : const LockedFeature(
                compact: true,
                title: 'Шаги приготовления скрыты',
                message: 'Пошаговый рецепт доступен после входа в аккаунт.',
              );

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              IconButton(
                tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                onPressed: () => toggleFavoriteOrAskToSignIn(context, recipe),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= _twoColumnBreakpoint;
              final ingredientsSection =
                  _IngredientsSection(ingredients: recipe.ingredients);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RecipeHeader(recipe: recipe),
                        const SizedBox(height: 16),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: ingredientsSection),
                              const SizedBox(width: 16),
                              Expanded(flex: 3, child: stepsSection),
                            ],
                          )
                        else ...[
                          ingredientsSection,
                          const SizedBox(height: 16),
                          stepsSection,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(recipe.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      RecipeMetaItem(
                        icon: Icons.schedule,
                        text: '${recipe.cookingMinutes} мин',
                      ),
                      RecipeMetaItem(
                        icon: Icons.signal_cellular_alt,
                        text: recipe.difficulty.label,
                      ),
                      RecipeMetaItem(
                        icon: Icons.people_outline,
                        text: '${recipe.servings} порц.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ингредиенты', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final ingredient in ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle,
                          size: 8, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ingredient)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Приготовление', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var index = 0; index < steps.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(steps[index])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
