const List<String> _weekdays = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const List<String> _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Ex.: "Quarta-feira, 12 de novembro"
String formatLongDate(DateTime d) {
  return '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]}';
}

/// Ex.: "12/11/2026"
String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// Ex.: "08:30"
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// Ex.: "12/11/2026 às 08:30"
String formatDateTime(DateTime d) => '${formatDate(d)} às ${formatTime(d)}';

/// "4" para 4.0 e "4.5" para 4.5
String formatWeight(double weight) {
  return weight == weight.roundToDouble()
      ? weight.toStringAsFixed(0)
      : weight.toStringAsFixed(1);
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
