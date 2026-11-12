import 'package:flutter/material.dart';

enum ReminderCategory {
  alimentacao('Alimentação', Icons.restaurant_rounded),
  passeio('Passeio', Icons.directions_walk_rounded),
  medicacao('Medicação', Icons.medication_rounded),
  vacina('Vacina', Icons.vaccines_outlined),
  banho('Banho', Icons.shower_outlined),
  desparasitacao('Desparasitação', Icons.bug_report_outlined),
  outro('Outro', Icons.event_note_rounded);

  const ReminderCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  static ReminderCategory fromName(String name) {
    return values.firstWhere((c) => c.name == name, orElse: () => outro);
  }
}

class Reminder {
  final int? id;
  final int petId;
  final String? petName; // Preenchido apenas em consultas com JOIN
  final String title;
  final ReminderCategory category;
  final DateTime dateTime;
  final bool done;
  final String notes;

  const Reminder({
    this.id,
    required this.petId,
    this.petName,
    required this.title,
    required this.category,
    required this.dateTime,
    this.done = false,
    this.notes = '',
  });

  Reminder copyWith({bool? done}) {
    return Reminder(
      id: id,
      petId: petId,
      petName: petName,
      title: title,
      category: category,
      dateTime: dateTime,
      done: done ?? this.done,
      notes: notes,
    );
  }

  factory Reminder.fromMap(Map<String, Object?> map) {
    return Reminder(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      petName: map['pet_name'] as String?,
      title: map['title'] as String,
      category: ReminderCategory.fromName(map['category'] as String),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      done: (map['done'] as int) == 1,
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'pet_id': petId,
      'title': title,
      'category': category.name,
      'date_time': dateTime.millisecondsSinceEpoch,
      'done': done ? 1 : 0,
      'notes': notes,
    };
  }
}
