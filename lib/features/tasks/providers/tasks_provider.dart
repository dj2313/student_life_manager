import 'package:flutter/material.dart';
import '../../../data/models/todo.dart';

class TasksProvider with ChangeNotifier {
  List<Todo> _tasks = [];

  List<Todo> get tasks => _tasks;
  List<Todo> get todayTasks =>
      _tasks.where((task) => _isToday(task.dueDate)).toList();
  List<Todo> get tomorrowTasks =>
      _tasks.where((task) => _isTomorrow(task.dueDate)).toList();
  List<Todo> get weekTasks =>
      _tasks.where((task) => _isThisWeek(task.dueDate)).toList();

  int get completedCount => _tasks.where((task) => task.completed).length;
  int get totalCount => _tasks.length;

  TasksProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _tasks = [
      Todo(
        id: '1',
        title: 'German homework',
        description: 'Complete exercise 5 and 6',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        completed: false,
        priority: 'high',
        category: 'Study',
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '2',
        title: 'Submit assignment',
        description: 'Upload PDF to portal',
        dueDate: DateTime.now().add(const Duration(hours: 5)),
        completed: false,
        priority: 'high',
        category: 'Study',
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '3',
        title: 'Buy groceries',
        description: 'Pantry update',
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        completed: true,
        priority: 'medium',
        category: 'Shopping',
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '4',
        title: 'Pay electricity bill',
        description: 'Flat management',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        completed: false,
        priority: 'high',
        category: 'Finance',
        createdAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  void addTask(Todo task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].completed = !_tasks[index].completed;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return date.isAfter(now.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd);
  }
}
