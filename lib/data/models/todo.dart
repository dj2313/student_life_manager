class Todo {
  late String id;
  late String title;
  late String priority; // 'high', 'medium', 'low'
  late DateTime dueDate;
  late bool completed;
  late String category; // 'Study', 'Money', 'Personal', 'Govt'
  String? description;
  late DateTime createdAt;

  // New fields for recurring habits
  late bool isRecurring;
  String? recurrenceInterval; // 'Daily', 'Weekly'

  // Pomodoro progress
  int pomodoroSessions;

  late bool shouldNotify;

  Todo({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.completed = false,
    required this.category,
    this.description,
    required this.createdAt,
    this.isRecurring = false,
    this.recurrenceInterval,
    this.pomodoroSessions = 0,
    this.shouldNotify = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'pomodoroSessions': pomodoroSessions,
      'shouldNotify': shouldNotify,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'] ?? false,
      category: json['category'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      isRecurring: json['isRecurring'] ?? false,
      recurrenceInterval: json['recurrenceInterval'],
      pomodoroSessions: json['pomodoroSessions'] ?? 0,
      shouldNotify: json['shouldNotify'] ?? false,
    );
  }
}
