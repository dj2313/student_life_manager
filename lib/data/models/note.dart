import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  late String id;
  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;
  List<String>? tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.parse(date);
      } else {
        return DateTime.now();
      }
    }

    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }
}
