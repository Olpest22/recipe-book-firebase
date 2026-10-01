import 'package:flutter/material.dart';

import '../data/recipes_data.dart';
import '../utils/app_scope.dart';
import '../utils/auth_navigation.dart';
import '../widgets/locked_feature.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';

/// Избранные рецепты. Гость вместо списка видит предложение войти.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ListenableBuilder(
        listenable: Listenable.merge(
          [scope.authService, scope.favoritesService],
        ),
        builder: (context, _) {
          // Ограничение функциональности для неавторизованных пользователей.
          if (!scope.authService.isSignedIn) {
            return const LockedFeature(
              title: 'Избранное доступно после входа',
              message: 'Сохраняйте понравившиеся рецепты, чтобы быстро '
                  'находить их. Для этого войдите в аккаунт или '
                  'зарегистрируйтесь.',
            );
          }

          final favoriteRecipes = allRecipes
              .where((r) => scope.favoritesService.isFavorite(r.id))
              .toList();

          if (favoriteRecipes.isEmpty) {
            return const _EmptyFavorites();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: recipeGridDelegate(context),
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
              return RecipeCard(
                recipe: recipe,
                isFavorite: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailsScreen(recipe: recipe),
                  ),
                ),
                onFavoriteTap: () =>
                    toggleFavoriteOrAskToSignIn(context, recipe),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Пока пусто', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Нажмите ♡ на карточке рецепта, чтобы добавить его сюда.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
