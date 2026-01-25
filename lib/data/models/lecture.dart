class Lecture {
  late String id;
  late String uniType; // 'public' or 'private'
  late String subject;
  late int dayOfWeek; // 1-7 (Monday-Sunday)
  late String time; // e.g., "10:00"
  late String room;

  String? professor;
  String? notes;

  Lecture({
    required this.id,
    required this.uniType,
    required this.subject,
    required this.dayOfWeek,
    required this.time,
    required this.room,
    this.professor,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniType': uniType,
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'time': time,
      'room': room,
      'professor': professor,
      'notes': notes,
    };
  }

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      uniType: json['uniType'],
      subject: json['subject'],
      dayOfWeek: json['dayOfWeek'],
      time: json['time'],
      room: json['room'],
      professor: json['professor'],
      notes: json['notes'],
    );
  }
}
