import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../utils/formatters.dart';

/// Linha reutilizável de lembrete: ícone colorido por categoria, estado concluído e ações.
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
    final done = reminder.done;
    final color = done ? kMutedColor : reminder.category.color;
    final when = showDate
        ? formatRelativeDateTime(reminder.dateTime)
        : formatTime(reminder.dateTime);
    final petLabel = reminder.petName ?? 'Sem animal';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(reminder.category.icon, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: done ? kMutedColor : kInkColor,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$petLabel • $when',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kMutedColor,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: done,
                          activeColor: color,
                          shape: const CircleBorder(),
                          onChanged: (value) => onToggle(value ?? false),
                        ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.redAccent,
                            tooltip: 'Remover',
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
