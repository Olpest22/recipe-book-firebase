import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_scope.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_form_layout.dart';
import '../../widgets/form_error_banner.dart';
import 'sign_in_screen.dart';

/// Экран регистрации нового пользователя в Firebase Authentication.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    // Сначала проверяем форму локально, чтобы не отправлять
    // в Firebase заведомо некорректные данные.
    if (!_formKey.currentState!.validate()) return;

    final authService = AppScope.of(context).authService;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _nameController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authService.signUp(
        name: name,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // После регистрации Firebase сразу авторизует пользователя.
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Аккаунт создан. Добро пожаловать, $name!')),
      );
    } on AuthFailure catch (failure) {
      // Ошибки Firebase: email уже занят, слабый пароль, нет сети и т. д.
      if (!mounted) return;
      setState(() => _errorMessage = failure.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthFormLayout(
        icon: Icons.person_add_alt_1,
        title: 'Регистрация',
        subtitle: 'Создайте аккаунт, чтобы пользоваться всеми функциями',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  helperText: 'Минимум 6 символов, буквы и цифры',
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
                validator: Validators.newPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isPasswordHidden,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signUp(),
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator:
                    Validators.confirmPassword(() => _passwordController.text),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                FormErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Зарегистрироваться'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _openSignIn,
                child: const Text('Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
