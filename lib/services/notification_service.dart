import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

/// Notificações locais: avisa o utilizador à hora de cada lembrete.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _channelId = 'lembretes_petcare';
  static const _channelName = 'Lembretes de cuidados';
  static const _channelDescription = 'Vacinas, banhos, medicação e passeios';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Chamar uma vez no arranque. Em web não há notificações locais.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();
    try {
      final localName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Se não conseguir detetar o fuso, fica em UTC.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Pede permissão ao utilizador (obrigatório no Android 13+).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Agenda a notificação do lembrete (se ainda estiver no futuro e não concluído).
  Future<void> scheduleReminder(Reminder reminder) async {
    final id = reminder.id;
    if (!_initialized || id == null) return;

    await cancelReminder(id);
    if (reminder.done || !reminder.dateTime.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id,
      title: '${reminder.category.label}: ${reminder.title}',
      body: reminder.petName == null
          ? 'Lembrete de cuidados'
          : 'Para ${reminder.petName}',
      scheduledDate: tz.TZDateTime.from(reminder.dateTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Inexato mas sem permissão especial de alarmes exatos.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id: id);
  }
}
