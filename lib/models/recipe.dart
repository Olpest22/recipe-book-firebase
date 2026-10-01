enum Difficulty {
  easy('Легко'),
  medium('Средне'),
  hard('Сложно');

  const Difficulty(this.label);

  final String label;
}

/// Рецепт. Каталог и ингредиенты доступны всем,
/// пошаговые инструкции ([steps]) — только после входа.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.cookingMinutes,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final int cookingMinutes;
  final int servings;
  final Difficulty difficulty;
  final List<String> ingredients;
  final List<String> steps;
}
