import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/utils/validators.dart';

void main() {
  group('Validators.petName', () {
    test('rejeita nome vazio ou só com espaços', () {
      expect(Validators.petName(null), isNotNull);
      expect(Validators.petName(''), isNotNull);
      expect(Validators.petName('   '), isNotNull);
    });

    test('aceita nome válido', () {
      expect(Validators.petName('Rex'), isNull);
    });

    test('rejeita nomes com mais de 40 caracteres', () {
      expect(Validators.petName('a' * 41), isNotNull);
      expect(Validators.petName('a' * 40), isNull);
    });
  });

  group('Validators.weight', () {
    test('rejeita valores não numéricos', () {
      expect(Validators.weight('abc'), isNotNull);
      expect(Validators.weight('NaN'), isNotNull);
      expect(Validators.weight('Infinity'), isNotNull);
    });

    test('rejeita valores não positivos', () {
      expect(Validators.weight('0'), isNotNull);
      expect(Validators.weight('-3'), isNotNull);
    });

    test('aceita números positivos com ponto ou vírgula', () {
      expect(Validators.weight('4.5'), isNull);
      expect(Validators.weight('4,5'), isNull);
      expect(Validators.weight('12'), isNull);
    });

    test('rejeita pesos absurdamente altos', () {
      expect(Validators.weight('500'), isNotNull);
    });
  });

  group('Validators.age', () {
    test('aceita idades entre 0 e 40', () {
      expect(Validators.age('0'), isNull);
      expect(Validators.age('40'), isNull);
    });

    test('rejeita idades fora do intervalo ou inválidas', () {
      expect(Validators.age('-1'), isNotNull);
      expect(Validators.age('41'), isNotNull);
      expect(Validators.age('2.5'), isNotNull);
      expect(Validators.age(''), isNotNull);
    });
  });

  group('Validators.email e password', () {
    test('email', () {
      expect(Validators.email('joao@mail.com'), isNull);
      expect(Validators.email('joao.mail.com'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('password tem pelo menos 6 caracteres', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });
}
