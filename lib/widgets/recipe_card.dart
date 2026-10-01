import 'package:flutter/material.dart';

import '../models/recipe.dart';

/// Сетка карточек, которая подстраивается под ширину экрана:
/// на телефоне 1–2 колонки, на планшете и в альбомной ориентации — больше.
/// Высота карточки растёт вместе с системным размером шрифта.
SliverGridDelegate recipeGridDelegate(BuildContext context) {
  final textScale =
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6).toDouble();
  return SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 360,
    mainAxisExtent: 100 + 124 * textScale,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
  );
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.primaryContainer,
                      child: Center(
                        child: Text(recipe.emoji,
                            style: const TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      tooltip: isFavorite
                          ? 'Убрать из избранного'
                          : 'В избранное',
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        RecipeMetaItem(
                          icon: Icons.schedule,
                          text: '${recipe.cookingMinutes} мин',
                        ),
                        const SizedBox(width: 16),
                        RecipeMetaItem(
                          icon: Icons.signal_cellular_alt,
                          text: recipe.difficulty.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Иконка и подпись: время, сложность, порции.
class RecipeMetaItem extends StatelessWidget {
  const RecipeMetaItem({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
