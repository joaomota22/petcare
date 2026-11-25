import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLoginMode = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final ok = _isLoginMode
        ? await _auth.login(email, password)
        : await _auth.register(email, password);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      _showError(
        _isLoginMode
            ? 'Email ou palavra-passe incorretos'
            : 'Este email já está registado',
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.palette.danger,
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: Space.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Space.l),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLoginMode ? 'Entrar' : 'Criar conta',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: Space.xxs),
                            Text(
                              _isLoginMode
                                  ? 'Continue a acompanhar os cuidados dos seus animais'
                                  : 'Guarde os cuidados dos seus animais num só lugar',
                              style: TextStyle(color: p.muted, height: 1.45),
                            ),
                            const SizedBox(height: Space.l),
                            CustomTextField(
                              controller: _emailCtrl,
                              label: 'Email',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: Space.s),
                            CustomTextField(
                              controller: _passwordCtrl,
                              label: 'Palavra-passe',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: Validators.password,
                            ),
                            const SizedBox(height: Space.l),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: p.onPrimary,
                                      ),
                                    )
                                  : Text(_isLoginMode ? 'Entrar' : 'Registar'),
                            ),
                            const SizedBox(height: Space.xs),
                            TextButton(
                              onPressed: _submitting ? null : _toggleMode,
                              child: Text(
                                _isLoginMode
                                    ? 'Não tem conta? Registe-se aqui'
                                    : 'Já tem conta? Entre aqui',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marca e frase do produto.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: p.primary,
                borderRadius: BorderRadius.circular(Radii.s),
              ),
              child: Icon(Icons.pets, size: 18, color: p.onPrimary),
            ),
            const SizedBox(width: Space.s),
            Text(
              'PetCare 360',
              style: TextStyle(
                color: p.ink,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.l),
        Text(
          'Saúde, alimentação e compromissos dos seus animais num só lugar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
      ],
    );
  }
}
