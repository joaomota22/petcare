import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/models/pet.dart';
import 'package:petcare/models/reminder.dart';
import 'package:petcare/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Pet _pet(String name, {double weight = 4.0}) => Pet(
      name: name,
      species: 'Cão',
      breed: 'Labrador',
      age: 3,
      weight: weight,
      gender: 'Macho',
    );

Reminder _reminder(int petId, DateTime when, {String title = 'Vacina'}) =>
    Reminder(
      petId: petId,
      title: title,
      category: ReminderCategory.vacina,
      dateTime: when,
    );

void main() {
  setUpAll(() {
    // Usa SQLite nativo no computador (os testes não correm num emulador).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseService db;

  setUp(() {
    db = DatabaseService(databasePath: inMemoryDatabasePath);
  });

  tearDown(() async {
    await db.close();
  });

  group('Animais (CRUD)', () {
    test('insere e lista animais por ordem alfabética', () async {
      await db.insertPet(_pet('Thor'));
      await db.insertPet(_pet('bela'));
      await db.insertPet(_pet('Ana'));

      final names = (await db.getPets()).map((p) => p.name).toList();
      expect(names, ['Ana', 'bela', 'Thor']);
    });

    test('ao inserir, regista o peso inicial no histórico', () async {
      final id = await db.insertPet(_pet('Rex', weight: 12.5));

      final history = await db.getWeightHistory(id);
      expect(history, hasLength(1));
      expect(history.first.weight, 12.5);
    });

    test('atualizar sem mudar o peso não cria registo novo no histórico', () async {
      final id = await db.insertPet(_pet('Rex'));
      final pet = (await db.getPets()).single;

      await db.updatePet(Pet(
        id: id,
        name: 'Rex Jr',
        species: pet.species,
        breed: pet.breed,
        age: 4,
        weight: pet.weight,
        gender: pet.gender,
      ));

      expect((await db.getPets()).single.name, 'Rex Jr');
      expect(await db.getWeightHistory(id), hasLength(1));
    });

    test('atualizar com peso novo acrescenta ao histórico', () async {
      final id = await db.insertPet(_pet('Rex', weight: 10));
      final pet = (await db.getPets()).single;

      await db.updatePet(Pet(
        id: id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        weight: 11.5,
        gender: pet.gender,
      ));

      final history = await db.getWeightHistory(id);
      expect(history.map((w) => w.weight), [10, 11.5]);
      expect((await db.getPets()).single.weight, 11.5);
    });

    test('addWeight atualiza o peso atual e o histórico', () async {
      final id = await db.insertPet(_pet('Mia', weight: 3));

      // Data futura para ficar depois do registo inicial (feito com DateTime.now()).
      final now = DateTime.now();
      final later = DateTime(now.year, now.month, now.day + 30, 12); // sem microssegundos (a BD guarda ms)
      await db.addWeight(id, 3.4, at: later);

      expect((await db.getPets()).single.weight, 3.4);
      final history = await db.getWeightHistory(id);
      expect(history.last.weight, 3.4);
      expect(history.last.recordedAt, later);
    });

    test('remover animal apaga em cascata o histórico e os lembretes', () async {
      final petId = await db.insertPet(_pet('Bolinhas'));
      await db.addWeight(petId, 5);
      await db.insertReminder(_reminder(petId, DateTime(2026, 5, 1, 9)));

      await db.deletePet(petId);

      expect(await db.getPets(), isEmpty);
      expect(await db.getWeightHistory(petId), isEmpty);
      expect(await db.getReminders(), isEmpty);
    });
  });

  group('Lembretes (CRUD)', () {
    test('lembrete devolve o nome do animal (JOIN)', () async {
      final petId = await db.insertPet(_pet('Luna'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 1, 10)));

      final reminder = (await db.getReminders()).single;
      expect(reminder.petName, 'Luna');
      expect(reminder.category, ReminderCategory.vacina);
    });

    test('filtra lembretes por intervalo de datas (um dia)', () async {
      final petId = await db.insertPet(_pet('Luna'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 1, 8), title: 'ontem'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 2, 8), title: 'hoje'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 2, 23), title: 'hoje tarde'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 3, 0), title: 'amanhã'));

      final today = await db.getRemindersBetween(
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 3),
      );

      expect(today.map((r) => r.title), ['hoje', 'hoje tarde']);
    });

    test('próximos lembretes excluem concluídos e passados', () async {
      final petId = await db.insertPet(_pet('Luna'));
      final now = DateTime(2026, 6, 10, 12);
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 9), title: 'passado'));
      final feito = await db.insertReminder(_reminder(petId, DateTime(2026, 6, 11), title: 'feito'));
      await db.insertReminder(_reminder(petId, DateTime(2026, 6, 12), title: 'futuro'));
      await db.setReminderDone(feito, true);

      final upcoming = await db.getUpcomingReminders(now);

      expect(upcoming.map((r) => r.title), ['futuro']);
    });

    test('marcar como concluído e atualizar', () async {
      final petId = await db.insertPet(_pet('Luna'));
      final id = await db.insertReminder(_reminder(petId, DateTime(2026, 6, 1)));

      await db.setReminderDone(id, true);
      expect((await db.getReminders()).single.done, isTrue);

      final current = (await db.getReminders()).single;
      await db.updateReminder(current.copyWith(title: 'Vacina anual'));
      expect((await db.getReminders()).single.title, 'Vacina anual');
    });

    test('remover lembrete', () async {
      final petId = await db.insertPet(_pet('Luna'));
      final id = await db.insertReminder(_reminder(petId, DateTime(2026, 6, 1)));

      await db.deleteReminder(id);

      expect(await db.getReminders(), isEmpty);
    });
  });

  test('caminho por defeito (o que a app usa) abre, grava e lê', () async {
    final real = DatabaseService(); // sem databasePath: usa getDatabasesPath()
    try {
      final id = await real.insertPet(_pet('Caminho real'));
      expect((await real.getPets()).map((p) => p.name), contains('Caminho real'));
      await real.deletePet(id);
      expect(await real.getPets(), isEmpty);
    } finally {
      await real.close();
    }
  });

  test('cada escrita notifica os ecrãs (DatabaseService.changes)', () async {
    final before = DatabaseService.changes.value;

    final petId = await db.insertPet(_pet('Nina'));
    await db.addWeight(petId, 2.2);

    expect(DatabaseService.changes.value, greaterThanOrEqualTo(before + 2));
  });
}
