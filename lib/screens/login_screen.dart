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
            ? 'Email ou palavra-passe incorretos.'
            : 'Este email já está registado.',
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
        backgroundColor: Colors.redAccent,
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.palette.brandGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Header(isLoginMode: _isLoginMode),
                    const SizedBox(height: 28),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLoginMode ? 'Entrar' : 'Criar conta',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: context.palette.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoginMode
                                    ? 'Bem-vindo de volta! Continue a cuidar dos seus animais.'
                                    : 'Registe-se em segundos e comece a organizar os cuidados.',
                                style: TextStyle(
                                  color: context.palette.muted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                controller: _emailCtrl,
                                label: 'Email',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validators.email,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passwordCtrl,
                                label: 'Palavra-passe',
                                icon: Icons.lock_outline_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator: Validators.password,
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(_isLoginMode ? 'Entrar' : 'Registar'),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _submitting ? null : _toggleMode,
                                child: Text(
                                  _isLoginMode
                                      ? 'Não tem conta? Registe-se aqui'
                                      : 'Já tem conta? Entre aqui',
                                  style: TextStyle(
                                    color: context.palette.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
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
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isLoginMode});

  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          ),
          child: const Icon(Icons.pets_rounded, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 14),
        const Text(
          'PetCare 360',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Saúde, alimentação e compromissos\ndos seus animais num só lugar',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
        ),
      ],
    );
  }
}
