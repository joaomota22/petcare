import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/formatters.dart';

/// Carimbo de data, como uma entrada no boletim de vacinas: dia e mês abreviado.
class DateStamp extends StatelessWidget {
  const DateStamp({super.key, required this.date, this.dimmed = false});

  final DateTime date;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 44,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(Radii.s),
        border: Border.all(color: p.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.w500,
              fontFeatures: kTabular,
              color: dimmed ? p.faint : p.ink,
            ),
          ),
          Text(
            formatShortMonth(date),
            style: TextStyle(fontSize: 11, height: 1.2, color: p.faint),
          ),
        ],
      ),
    );
  }
}
