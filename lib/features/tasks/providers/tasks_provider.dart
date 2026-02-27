import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/todo.dart';
import '../../../core/services/notification_service.dart';

class TasksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  List<Todo> _tasks = [];
  bool _isLoading = false;
  String _selectedCategoryFilter = 'All';

  List<Todo> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get _uid => _auth.currentUser?.uid ?? 'guest_user';
  String get selectedCategoryFilter => _selectedCategoryFilter;

  List<Todo> get filteredTasks => _selectedCategoryFilter == 'All'
      ? _tasks
      : _tasks
            .where((task) => task.category == _selectedCategoryFilter)
            .toList();

  List<Todo> get todayTasks =>
      filteredTasks.where((task) => _isToday(task.dueDate)).toList();
  List<Todo> get tomorrowTasks =>
      filteredTasks.where((task) => _isTomorrow(task.dueDate)).toList();
  List<Todo> get weekTasks =>
      filteredTasks.where((task) => _isThisWeek(task.dueDate)).toList();

  int get completedCount => _tasks.where((task) => task.completed).length;
  int get totalCount => _tasks.length;

  TasksProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await fetchTasks();
    } catch (e) {
      debugPrint('TasksProvider Initialization Error: $e');
      _loadMockData();
    }
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('tasks')
          .orderBy('dueDate', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _tasks = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Todo.fromJson(data);
        }).toList();
      } else {
        _tasks = [];
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      if (_tasks.isEmpty) _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        id: '5',
        title: 'Practice German Vocabulary 🇩🇪',
        description: 'Daily habit for fluency',
        dueDate: DateTime.now(),
        completed: false,
        priority: 'high',
        category: 'Study',
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrenceInterval: 'Daily',
      ),
    ];
    notifyListeners();
  }

  Future<void> addTask(Todo task) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson());

      if (task.shouldNotify) {
        // Show an immediate confirmation notification
        await _notificationService.showNotification(
          id: task.id.hashCode + 10000,
          title: '✅ Task Scheduled',
          body:
              '"${task.title}" reminder set for ${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
        );
        // Schedule the actual reminder at the task's due date/time
        await _notificationService.scheduleNotification(
          id: task.id.hashCode,
          title: '⏰ Task Due: ${task.title}',
          body: "Your task is due now! Don't forget to complete it.",
          scheduledDate: task.dueDate,
        );
      }

      _tasks.insert(0, task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.completed = !task.completed;

      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('tasks')
            .doc(id)
            .update({'completed': task.completed});

        if (task.completed && task.isRecurring) {
          _handleRecurringTask(task);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating task: $e');
      }
    }
  }

  Future<void> incrementPomodoro(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].pomodoroSessions++;
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('tasks')
            .doc(id)
            .update({'pomodoroSessions': _tasks[index].pomodoroSessions});
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating pomodoro: $e');
      }
    }
  }

  void _handleRecurringTask(Todo task) {
    DateTime nextDate;
    if (task.recurrenceInterval == 'Daily') {
      nextDate = task.dueDate.add(const Duration(days: 1));
    } else {
      nextDate = task.dueDate.add(const Duration(days: 7));
    }

    final newTask = Todo(
      id: '${task.id.split('_')[0]}_next_${nextDate.millisecondsSinceEpoch}',
      title: task.title,
      description: task.description,
      priority: task.priority,
      dueDate: nextDate,
      category: task.category,
      createdAt: DateTime.now(),
      isRecurring: true,
      recurrenceInterval: task.recurrenceInterval,
    );
    addTask(newTask);
  }

  Future<void> updateTask(Todo updatedTask) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('tasks')
          .doc(updatedTask.id)
          .update(updatedTask.toJson());

      // Cancel any existing notification for this task
      await _notificationService.cancelNotification(updatedTask.id.hashCode);

      if (updatedTask.shouldNotify) {
        await _notificationService.showNotification(
          id: updatedTask.id.hashCode + 10000,
          title: '✅ Task Reminder Updated',
          body:
              '"${updatedTask.title}" reminder rescheduled for ${updatedTask.dueDate.hour.toString().padLeft(2, '0')}:${updatedTask.dueDate.minute.toString().padLeft(2, '0')}',
        );
        await _notificationService.scheduleNotification(
          id: updatedTask.id.hashCode,
          title: '⏰ Task Due: ${updatedTask.title}',
          body: "Your task is due now! Don't forget to complete it.",
          scheduledDate: updatedTask.dueDate,
        );
      }

      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('tasks')
          .doc(id)
          .delete();
      // Cancel any scheduled notification
      await _notificationService.cancelNotification(id.hashCode);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
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
