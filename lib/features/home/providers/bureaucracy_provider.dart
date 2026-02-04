import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/student_os_models.dart';

class BureaucracyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<BureaucracyTask> _tasks = [];
  bool _isLoading = false;

  List<BureaucracyTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  BureaucracyProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('bureaucracy_tasks')
          .orderBy('createdAt', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _tasks = snapshot.docs.map((doc) => BureaucracyTask.fromJson(doc.data())).toList();
      } else {
        _loadInitialTasks();
        // Save initial tasks to Firestore
        for (final task in _tasks) {
          await _firestore
              .collection('users')
              .doc(_uid)
              .collection('bureaucracy_tasks')
              .doc(task.id)
              .set(task.toJson());
        }
      }
    } catch (e) {
      debugPrint('Error fetching bureaucracy tasks: $e');
      _loadInitialTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadInitialTasks() {
    _tasks = [
      BureaucracyTask(
        id: '1',
        title: 'City Registration (Anmeldung)',
        description: 'Register your address at the Burgeramt within 14 days of arrival.',
        category: 'Legal',
        requiredDocuments: ['Passport', 'Rental Agreement (Wohnungsgeberbestätigung)'],
      ),
      BureaucracyTask(
        id: '2',
        title: 'Health Insurance',
        description: 'Activate your health insurance (TK, AOK, etc.) for enrollment.',
        category: 'Health',
        requiredDocuments: ['Passport', 'Zulassungsbescheinigung'],
      ),
      BureaucracyTask(
        id: '3',
        title: 'Residence Permit',
        description: 'Apply for your study residence permit at the Ausländerbehörde.',
        category: 'Immigration',
        requiredDocuments: ['Proof of Funds', 'Insurance', 'Passport', 'Photos'],
      ),
      BureaucracyTask(
        id: '4',
        title: 'Bank Account / Blocked Account',
        description: 'Activate your blocked account and open a local Sparkasse/N26 account.',
        category: 'Finance',
      ),
    ];
  }

  Future<void> updateTaskStatus(String id, BureaucracyStatus status) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final updatedTask = _tasks[index].copyWith(status: status);
        _tasks[index] = updatedTask;
        notifyListeners();

        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('bureaucracy_tasks')
            .doc(id)
            .update({'status': status.name});
      }
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  Future<void> addTask(BureaucracyTask task) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('bureaucracy_tasks')
          .doc(task.id)
          .set(task.toJson());
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding bureaucracy task: $e');
    }
  }

  double get completionProgress {
    if (_tasks.isEmpty) return 0;
    final completed = _tasks
        .where((t) => t.status == BureaucracyStatus.completed)
        .length;
    return completed / _tasks.length;
  }
}
