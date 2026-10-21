class WeightEntry {
  final String id;
  final double weightKg;
  final DateTime date;

  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'weightKg': weightKg,
        'date': date.toIso8601String(),
      };

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id']?.toString() ?? '',
      weightKg: (map['weightKg'] as num).toDouble(),
      date: DateTime.parse(map['date'].toString()),
    );
  }
}
