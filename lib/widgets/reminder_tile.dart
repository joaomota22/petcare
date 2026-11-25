import 'package:flutter/material.dart';

import 'pressable.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../utils/formatters.dart';
import 'date_stamp.dart';

/// Linha de lembrete: carimbo de data, título, tipo e hora, e círculo de conclusão.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = reminder.done;
    final petLabel = reminder.petName ?? 'Sem animal';

    return Pressable(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Space.xs),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Space.s,
                Space.s,
                onDelete == null ? Space.m : Space.xxs,
                Space.s,
              ),
              child: Row(
                children: [
                  DateStamp(date: reminder.dateTime, dimmed: done),
                  const SizedBox(width: Space.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: done ? p.faint : p.ink,
                            decoration: done ? TextDecoration.lineThrough : null,
                            decorationColor: p.faint,
                          ),
                        ),
                        const SizedBox(height: Space.xxs),
                        Row(
                          children: [
                            Icon(reminder.category.icon, size: 16, color: p.faint),
                            const SizedBox(width: Space.xxs),
                            Expanded(
                              child: Text(
                                '${reminder.category.label} · $petLabel · ${formatTime(reminder.dateTime)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.muted,
                                  fontSize: 13,
                                  fontFeatures: kTabular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  _DoneCircle(done: done, onTap: () => onToggle(!done)),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: p.faint,
                      tooltip: 'Remover',
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneCircle extends StatelessWidget {
  const _DoneCircle({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Marcar como por fazer' : 'Marcar como concluído',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.curve,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? p.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? p.success : p.faint.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: done
                  ? Icon(Icons.check, size: 16, color: p.surface)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
