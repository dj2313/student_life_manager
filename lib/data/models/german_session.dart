class GermanSession {
  late String id;
  late DateTime date;
  late int duration; // in minutes
  late String tutor;
  String? notes;

  late double progress; // 0.0 to 1.0
  String? topic;

  GermanSession({
    required this.id,
    required this.date,
    required this.duration,
    required this.tutor,
    this.notes,
    required this.progress,
    this.topic,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration,
      'tutor': tutor,
      'notes': notes,
      'progress': progress,
      'topic': topic,
    };
  }

  factory GermanSession.fromJson(Map<String, dynamic> json) {
    return GermanSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      tutor: json['tutor'],
      notes: json['notes'],
      progress: json['progress'],
      topic: json['topic'],
    );
  }
}
