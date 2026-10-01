import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_scope.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_form_layout.dart';
import '../../widgets/form_error_banner.dart';
import 'sign_up_screen.dart';

/// Экран входа по email и паролю через Firebase Authentication.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;
  bool _isEmailPrefilled = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Подставляем email прошлого входа (сохранён в shared_preferences).
    // В initState это сделать нельзя: AppScope ещё недоступен.
    if (!_isEmailPrefilled) {
      _emailController.text = AppScope.of(context).authService.lastEmail;
      _isEmailPrefilled = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authService = AppScope.of(context).authService;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Успешный вход: возвращаемся на экран, с которого пришли.
      // Он сам обновится, так как слушает AuthService.
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Вы вошли в аккаунт. Все функции доступны!')),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (Validators.email(_emailController.text) != null) {
      setState(() => _errorMessage =
          'Введите корректный email, чтобы восстановить пароль.');
      return;
    }

    final authService = AppScope.of(context).authService;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _errorMessage = null);

    try {
      await authService.sendPasswordReset(_emailController.text);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Если аккаунт существует, письмо для сброса пароля '
            'отправлено на ${_emailController.text.trim()}',
          ),
        ),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    }
  }

  void _openSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthFormLayout(
        icon: Icons.restaurant_menu,
        title: 'Вход',
        subtitle: 'Войдите, чтобы открыть пошаговые рецепты и избранное',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip:
                        _isPasswordHidden ? 'Показать пароль' : 'Скрыть пароль',
                    onPressed: () =>
                        setState(() => _isPasswordHidden = !_isPasswordHidden),
                    icon: Icon(_isPasswordHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: Validators.enteredPassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: const Text('Забыли пароль?'),
                ),
              ),
              if (_errorMessage != null) ...[
                FormErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Войти'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _openSignUp,
                child: const Text('Нет аккаунта? Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
