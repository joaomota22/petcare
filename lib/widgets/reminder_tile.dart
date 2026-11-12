import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../utils/formatters.dart';

/// Linha reutilizável de lembrete: ícone da categoria, estado concluído e ações.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    this.onTap,
    this.onDelete,
    this.showDate = true,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = reminder.done;
    final when = showDate
        ? formatDateTime(reminder.dateTime)
        : formatTime(reminder.dateTime);
    final petLabel = reminder.petName ?? 'Sem animal';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: done
                ? Colors.grey.shade200
                : scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            reminder.category.icon,
            color: done ? Colors.grey : scheme.primary,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          '$petLabel • ${reminder.category.label} • $when',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: done,
              onChanged: (value) => onToggle(value ?? false),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remover',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
