import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../utils/formatters.dart';

/// Linha de lembrete: caixa de ícone tingida pela categoria, texto e círculo de conclusão.
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(reminder.category.icon, color: color),
                ),
                const SizedBox(width: 14),
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
                          fontSize: 15.5,
                          color: done ? kMutedColor : kInkColor,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$petLabel • $when',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kMutedColor, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                _DoneCircle(
                  done: done,
                  color: kPrimaryColor,
                  onTap: () => onToggle(!done),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: kSecondaryColor,
                    tooltip: 'Remover',
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneCircle extends StatelessWidget {
  const _DoneCircle({required this.done, required this.color, required this.onTap});

  final bool done;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: done ? kTealColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: done ? kTealColor : color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
