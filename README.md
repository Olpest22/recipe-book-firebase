# recipe_book — авторизация с Firebase

«Книга рецептов» с регистрацией и входом по email и паролю через
**Firebase Authentication**. Приложением можно пользоваться без аккаунта,
но часть функций доступна только после входа.

## Что доступно гостю и пользователю

| Функция | Гость | После входа |
|---|:---:|:---:|
| Каталог и поиск рецептов | ✅ | ✅ |
| Ингредиенты рецепта | ✅ | ✅ |
| Пошаговые инструкции | 🔒 | ✅ |
| Избранное | 🔒 | ✅ |
| Профиль аккаунта | 🔒 | ✅ |

Гость видит баннер «Гостевой режим» в каталоге, значок замка на вкладке «Избранное»,
заглушки с кнопками «Войти / Создать аккаунт» вместо закрытых функций и диалог
при нажатии на «сердечко».

## Реализовано

- **Регистрация** (`createUserWithEmailAndPassword`) с именем пользователя;
  валидация email, пароля (6+ символов, буквы и цифры) и повтора пароля.
- **Вход** (`signInWithEmailAndPassword`) и восстановление пароля по email.
- **Обработка ошибок Firebase** с сообщениями на русском: email уже занят,
  неверный email или пароль, слабый пароль, нет сети, слишком много попыток.
- **Сохранение состояния:** сессию хранит Firebase Auth, поэтому после перезапуска
  пользователь остаётся в аккаунте. Через `shared_preferences` сохраняются email
  последнего входа (автозаполнение) и избранное каждого пользователя.
- **Выход** (`signOut`) с подтверждением: приложение переходит в гостевой режим,
  избранное и шаги рецептов снова блокируются.
- **Адаптивность:** на телефоне нижняя навигация, на планшете и в альбомной
  ориентации боковая панель; сетка карточек меняет число колонок; на широком
  экране рецепт выводится в две колонки; формы ограничены по ширине и прокручиваются.

## Структура

```
lib/
├── main.dart                    // инициализация Firebase и сервисов
├── app.dart                     // MaterialApp, темы
├── firebase_options.dart        // создаётся командой flutterfire configure
├── models/recipe.dart
├── data/recipes_data.dart       // каталог рецептов
├── services/
│   ├── auth_service.dart        // работа с Firebase Auth
│   ├── auth_errors.dart         // перевод ошибок Firebase
│   └── favorites_service.dart   // избранное (только для вошедших)
├── screens/
│   ├── main_shell.dart          // адаптивная навигация
│   ├── catalog_screen.dart
│   ├── recipe_details_screen.dart
│   ├── favorites_screen.dart
│   ├── profile_screen.dart
│   └── auth/ (sign_in_screen.dart, sign_up_screen.dart)
├── widgets/                     // карточки, заглушки, баннеры
└── utils/                       // AppScope, валидаторы, навигация
test/                            // тесты валидации и сообщений об ошибках
```

## Настройка и запуск

1. Создайте папки платформ:
   ```bash
   flutter create . --org com.example
   flutter pub get
   ```
2. В [Firebase Console](https://console.firebase.google.com) создайте проект и включите
   **Authentication → Sign-in method → Email/Password**.
3. Подключите Firebase к приложению (нужны Firebase CLI и FlutterFire CLI):
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Команда перезапишет `lib/firebase_options.dart` и добавит конфигурацию для Android и iOS.
4. Запуск:
   ```bash
   flutter run
   ```

Если сборка Android падает с ошибкой про `minSdkVersion`, укажите в
`android/app/build.gradle` (или `build.gradle.kts`) значение `minSdk = 23`.

Тесты: `flutter test`

> Файл `firebase_options.dart` содержит публичные параметры клиента Firebase
> (это не секретные ключи), поэтому его можно хранить в репозитории,
> чтобы проверяющий мог запустить проект.
