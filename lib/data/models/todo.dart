class Todo {
  late String id;
  late String title;
  late String priority; // 'high', 'medium', 'low'
  late DateTime dueDate;
  late bool completed;
  late String category; // 'Study', 'Finance', 'Personal', 'Shopping'
  String? description;
  late DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.completed = false,
    required this.category,
    this.description,
    required this.createdAt,
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
    );
  }
}
