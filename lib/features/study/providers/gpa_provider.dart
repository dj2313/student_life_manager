import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/student_os_models.dart';

class GPAProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AcademicModule> _modules = [];
  bool _isLoading = false;

  List<AcademicModule> get modules => _modules;
  bool get isLoading => _isLoading;

  String? get _uid => _auth.currentUser?.uid;

  GPAProvider() {
    _init();
  }

  Future<void> _init() async {
    await fetchModules();
  }

  Future<void> fetchModules() async {
    final uid = _uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('academic_modules')
          .orderBy('semester', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _modules = snapshot.docs
            .map((d) => AcademicModule.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching GPA modules: $e');
      _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockData() {
    if (_modules.isNotEmpty) return;
    _modules = [
      AcademicModule(
        id: '1',
        name: 'Mathematics I',
        ects: 6,
        grade: 1.3,
        semester: 'WiSe 23/24',
        isCompleted: true,
      ),
      AcademicModule(
        id: '2',
        name: 'Computer Science',
        ects: 8,
        grade: 1.7,
        semester: 'WiSe 23/24',
        isCompleted: true,
      ),
      AcademicModule(
        id: '3',
        name: 'German A1',
        ects: 5,
        grade: 2.0,
        semester: 'WiSe 23/24',
        isCompleted: true,
      ),
    ];
    notifyListeners();
  }

  Future<void> addModule(AcademicModule module) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('academic_modules')
          .add(module.toJson());

      final newModule = AcademicModule(
        id: docRef.id,
        name: module.name,
        ects: module.ects,
        grade: module.grade,
        semester: module.semester,
        isCompleted: module.isCompleted,
      );

      _modules.insert(0, newModule);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding module: $e');
    }
  }

  Future<void> updateModule(AcademicModule module) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('academic_modules')
          .doc(module.id)
          .update(module.toJson());

      final index = _modules.indexWhere((m) => m.id == module.id);
      if (index != -1) {
        _modules[index] = module;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating module: $e');
    }
  }

  Future<void> deleteModule(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('academic_modules')
          .doc(id)
          .delete();

      _modules.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting module: $e');
    }
  }

  double get currentGPA {
    double totalPoints = 0;
    int totalECTS = 0;

    for (var module in _modules) {
      if (module.grade != null && module.isCompleted) {
        totalPoints += (module.grade! * module.ects);
        totalECTS += module.ects;
      }
    }

    if (totalECTS == 0) return 0.0;
    return totalPoints / totalECTS;
  }

  int get totalCredits =>
      _modules.where((m) => m.isCompleted).fold(0, (sum, m) => sum + m.ects);

  Map<String, List<AcademicModule>> get modulesBySemester {
    Map<String, List<AcademicModule>> grouped = {};
    for (var m in _modules) {
      grouped.putIfAbsent(m.semester, () => []).add(m);
    }
    return grouped;
  }
}
