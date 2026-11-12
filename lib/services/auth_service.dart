import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Autenticação SIMULADA para o TP1: contas e sessão ficam guardadas no dispositivo.
/// Não é segura (a palavra-passe não é cifrada) e será substituída por
/// Firebase Authentication no TP2.
class AuthService {
  static const _usersKey = 'auth_users';
  static const _tokenKey = 'auth_session_token';

  /// Cria uma conta e inicia sessão. Devolve false se o email já existir.
  Future<bool> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    final key = _normalize(email);

    if (users.containsKey(key)) return false;

    users[key] = password;
    await prefs.setString(_usersKey, jsonEncode(users));
    await _createSession(prefs);
    return true;
  }

  /// Valida as credenciais e inicia sessão.
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);

    if (users[_normalize(email)] != password) return false;

    await _createSession(prefs);
    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  String _normalize(String email) => email.trim().toLowerCase();

  Map<String, String> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((email, password) => MapEntry(email, password as String));
  }

  /// "Token falso": 32 bytes aleatórios em base64, apenas para simular a sessão.
  Future<void> _createSession(SharedPreferences prefs) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return prefs.setString(_tokenKey, base64UrlEncode(bytes));
  }
}
