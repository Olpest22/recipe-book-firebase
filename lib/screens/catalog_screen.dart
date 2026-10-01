import 'package:flutter/material.dart';

import '../data/recipes_data.dart';
import '../models/recipe.dart';
import '../utils/app_scope.dart';
import '../utils/auth_navigation.dart';
import '../widgets/guest_banner.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';

/// Каталог рецептов с поиском. Доступен всем пользователям.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredRecipes {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return allRecipes;
    return allRecipes
        .where((recipe) => recipe.title.toLowerCase().contains(query))
        .toList();
  }

  void _openDetails(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Книга рецептов')),
      body: ListenableBuilder(
        // Перестраиваемся при входе/выходе и изменении избранного.
        listenable: Listenable.merge(
          [scope.authService, scope.favoritesService],
        ),
        builder: (context, _) {
          final recipes = _filteredRecipes;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Поиск рецептов',
                      leading: const Icon(Icons.search),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    if (!scope.authService.isSignedIn) ...[
                      const SizedBox(height: 16),
                      const GuestBanner(),
                    ],
                  ]),
                ),
              ),
              if (recipes.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Ничего не найдено')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid.builder(
                    gridDelegate: recipeGridDelegate(context),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        isFavorite: scope.favoritesService.isFavorite(recipe.id),
                        onTap: () => _openDetails(recipe),
                        onFavoriteTap: () =>
                            toggleFavoriteOrAskToSignIn(context, recipe),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
