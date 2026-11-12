import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/main.dart';
import 'package:petcare/screens/pet_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sem sessão abre o ecrã de login', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('PetCare 360'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('formulário de login valida campos vazios', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Introduza o email'), findsOneWidget);
    expect(find.text('Introduza a palavra-passe'), findsOneWidget);
  });

  testWidgets('formulário de animal valida nome vazio e peso não positivo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PetFormScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Peso (kg)'), '0');
    await tester.ensureVisible(find.text('Guardar animal'));
    await tester.tap(find.text('Guardar animal'));
    await tester.pumpAndSettle();

    expect(find.text('O nome não pode estar vazio'), findsOneWidget);
    expect(find.text('O peso deve ser um número positivo'), findsOneWidget);
  });

  testWidgets('alterna para o modo de registo', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('Registe-se aqui'));
    await tester.tap(find.textContaining('Registe-se aqui'));
    await tester.pumpAndSettle();

    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Registar'), findsOneWidget);
  });
}
