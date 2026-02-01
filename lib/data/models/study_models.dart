class StudyGoal {
  final String id;
  final String title;
  final DateTime deadline;
  final double targetProgress;
  double currentProgress;

  StudyGoal({
    required this.id,
    required this.title,
    required this.deadline,
    required this.targetProgress,
    this.currentProgress = 0,
  });
}

class GermanSession {
  final String id;
  final DateTime date;
  final double durationHours;
  final String topicsCovered;

  GermanSession({
    required this.id,
    required this.date,
    required this.durationHours,
    required this.topicsCovered,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'durationHours': durationHours,
    'topicsCovered': topicsCovered,
  };

  factory GermanSession.fromJson(Map<String, dynamic> json) => GermanSession(
    id: json['id'] ?? '',
    date: DateTime.parse(json['date']),
    durationHours: (json['durationHours'] ?? 0.0).toDouble(),
    topicsCovered: json['topicsCovered'] ?? '',
  );
}
