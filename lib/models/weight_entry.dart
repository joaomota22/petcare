/// Registo do peso de um animal numa data (histórico para o gráfico).
class WeightEntry {
  final int? id;
  final int petId;
  final double weight;
  final DateTime recordedAt;

  const WeightEntry({
    this.id,
    required this.petId,
    required this.weight,
    required this.recordedAt,
  });

  factory WeightEntry.fromMap(Map<String, Object?> map) {
    return WeightEntry(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'pet_id': petId,
      'weight': weight,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
    };
  }
}
