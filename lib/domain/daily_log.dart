import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';

class DailyLog {
  const DailyLog({
    required this.date,
    this.isPeriod = false,
    this.flow = FlowLevel.none,
    this.symptomIds = const {},
    this.notes = '',
    required this.updatedAt,
  });

  final DateTime date;
  final bool isPeriod;
  final FlowLevel flow;
  final Set<String> symptomIds;
  final String notes;
  final DateTime updatedAt;

  bool get isEmpty =>
      !isPeriod && flow == FlowLevel.none && symptomIds.isEmpty && notes.trim().isEmpty;

  DailyLog copyWith({
    DateTime? date,
    bool? isPeriod,
    FlowLevel? flow,
    Set<String>? symptomIds,
    String? notes,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      date: date ?? this.date,
      isPeriod: isPeriod ?? this.isPeriod,
      flow: flow ?? this.flow,
      symptomIds: symptomIds ?? this.symptomIds,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': dateKey(date),
    'isPeriod': isPeriod,
    'flow': flow.name,
    'symptomIds': symptomIds.toList()..sort(),
    'notes': notes,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    final symptoms = json['symptomIds'];
    return DailyLog(
      date: parseDateKey(json['date'] as String),
      isPeriod: json['isPeriod'] as bool? ?? false,
      flow: FlowLevel.fromName(json['flow'] as String?),
      symptomIds: {
        if (symptoms is Iterable) ...symptoms.map((item) => item.toString()),
      },
      notes: json['notes'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
