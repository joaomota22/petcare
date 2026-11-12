import '../models/reminder.dart';
import 'database_service.dart';
import 'notification_service.dart';

/// Junta a base de dados e as notificações: cada alteração a um lembrete
/// mantém a notificação agendada em sincronia.
class ReminderService {
  ReminderService._();

  static final _db = DatabaseService.instance;
  static final _notifications = NotificationService.instance;

  /// Cria ou atualiza o lembrete e (re)agenda a notificação.
  static Future<Reminder> save(Reminder reminder) async {
    final int id;
    if (reminder.id == null) {
      id = await _db.insertReminder(reminder);
    } else {
      await _db.updateReminder(reminder);
      id = reminder.id!;
    }
    final saved = reminder.copyWith(id: id);
    await _notifications.scheduleReminder(saved);
    return saved;
  }

  /// Marca como concluído/por fazer. Concluído cancela a notificação.
  static Future<void> setDone(Reminder reminder, bool done) async {
    await _db.setReminderDone(reminder.id!, done);
    await _notifications.scheduleReminder(reminder.copyWith(done: done));
  }

  static Future<void> delete(Reminder reminder) async {
    await _db.deleteReminder(reminder.id!);
    await _notifications.cancelReminder(reminder.id!);
  }

  /// Remove o animal e cancela as notificações dos seus lembretes.
  static Future<void> deletePet(int petId) async {
    final reminders = await _db.getReminders();
    for (final reminder in reminders.where((r) => r.petId == petId)) {
      await _notifications.cancelReminder(reminder.id!);
    }
    await _db.deletePet(petId);
  }
}
