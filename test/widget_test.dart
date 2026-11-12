import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sem sessão abre o ecrã de login', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('formulário de login valida campos vazios', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Introduza o email'), findsOneWidget);
    expect(find.text('Introduza a palavra-passe'), findsOneWidget);
  });

  testWidgets('alterna para o modo de registo', (tester) async {
    await tester.pumpWidget(const PetCareApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Registe-se aqui'));
    await tester.pumpAndSettle();

    expect(find.text('Criar nova conta'), findsOneWidget);
    expect(find.text('Registar'), findsOneWidget);
  });
}
