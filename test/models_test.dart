import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/models/pet.dart';
import 'package:petcare/models/reminder.dart';
import 'package:petcare/utils/formatters.dart';

void main() {
  group('Pet', () {
    test('toMap/fromMap mantém os dados', () {
      const pet = Pet(
        id: 3,
        name: 'Luna',
        species: 'Gato',
        breed: 'Persa',
        age: 4,
        weight: 4.5,
        gender: 'Fêmea',
        medicalNotes: 'Alérgica a frango',
      );

      final copy = Pet.fromMap(pet.toMap());

      expect(copy.id, 3);
      expect(copy.name, 'Luna');
      expect(copy.species, 'Gato');
      expect(copy.breed, 'Persa');
      expect(copy.age, 4);
      expect(copy.weight, 4.5);
      expect(copy.gender, 'Fêmea');
      expect(copy.medicalNotes, 'Alérgica a frango');
    });

    test('não envia o id quando ainda não existe (autoincrement)', () {
      const pet = Pet(
        name: 'Rex',
        species: 'Cão',
        breed: 'Labrador',
        age: 2,
        weight: 30,
        gender: 'Macho',
      );
      expect(pet.toMap().containsKey('id'), isFalse);
    });
  });

  group('Reminder', () {
    test('toMap/fromMap preserva data, estado e categoria', () {
      final date = DateTime(2026, 11, 12, 8, 30);
      final reminder = Reminder(
        id: 1,
        petId: 2,
        title: 'Vacina anual',
        category: ReminderCategory.vacina,
        dateTime: date,
        done: true,
      );

      final map = reminder.toMap();
      expect(map['done'], 1);
      expect(map['category'], 'vacina');

      final copy = Reminder.fromMap({...map, 'pet_name': 'Rex'});
      expect(copy.dateTime, date);
      expect(copy.done, isTrue);
      expect(copy.category, ReminderCategory.vacina);
      expect(copy.petName, 'Rex');
    });

    test('categoria desconhecida cai em "Outro"', () {
      expect(ReminderCategory.fromName('inexistente'), ReminderCategory.outro);
    });

    test('copyWith altera apenas o estado concluído', () {
      final reminder = Reminder(
        petId: 1,
        title: 'Banho',
        category: ReminderCategory.banho,
        dateTime: DateTime(2026, 1, 1),
      );
      expect(reminder.copyWith(done: true).done, isTrue);
      expect(reminder.copyWith(done: true).title, 'Banho');
    });
  });

  group('formatters', () {
    test('formatWeight', () {
      expect(formatWeight(4), '4');
      expect(formatWeight(4.5), '4.5');
    });

    test('formatLongDate em português', () {
      expect(formatLongDate(DateTime(2026, 11, 12)), 'Quinta-feira, 12 de novembro');
    });

    test('formatDateTime', () {
      expect(formatDateTime(DateTime(2026, 3, 5, 9, 7)), '05/03/2026 às 09:07');
    });
  });
}
