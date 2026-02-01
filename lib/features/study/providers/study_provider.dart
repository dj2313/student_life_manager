import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/lecture.dart';
import '../../../data/models/study_models.dart';
import '../../../data/models/university.dart';
import '../../../core/services/notification_service.dart';

class StudyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _germanLevel = 'A1';
  double _hoursLoggedThisWeek = 8;
  final double _weeklyTargetHours = 12;
  double _germanClassFees = 250.0;
  final Map<String, DateTime> _examDates = {'A1': DateTime(2026, 2, 16)};

  Map<String, String> _germanProgress = {
    'A1': 'Cleared',
    'A2': 'Completed',
    'B1': 'Pending',
    'B2': 'Pending',
    'C1': 'Pending',
    'C2': 'Pending',
  };

  List<Lecture> _todayLectures = [];
  List<GermanSession> _sessions = [];
  List<StudyGoal> _goals = [];
  List<University> _universities = [];

  String get germanLevel => _germanLevel;
  Map<String, String> get germanProgress => _germanProgress;
  double get hoursLoggedThisWeek => _hoursLoggedThisWeek;
  double get weeklyTargetHours => _weeklyTargetHours;
  double get germanClassFees => _germanClassFees;
  Map<String, DateTime> get examDates => _examDates;
  List<Lecture> get todayLectures => _todayLectures;
  List<GermanSession> get sessions => _sessions;
  List<StudyGoal> get goals => _goals;
  List<University> get universities => _universities;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  StudyProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await fetchData();
      await fetchUniversities();
      _loadMockData();
      _scheduleGermanExamReminders();
    } catch (e) {
      debugPrint('StudyProvider Initialization Error: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    _todayLectures = [
      Lecture(
        id: '1',
        uniType: 'Public',
        subject: 'German A1',
        dayOfWeek: DateTime.now().weekday,
        time: '10:00',
        room: 'Room 302',
        professor: 'Kalpesh Sir',
      ),
      Lecture(
        id: '2',
        uniType: 'Private', // Changed one to Private for testing
        subject: 'Computer Science',
        dayOfWeek: DateTime.now().weekday,
        time: '14:00',
        room: 'Lab 1',
        professor: 'Dr. Muller',
      ),
    ];

    _goals = [
      StudyGoal(
        id: '1',
        title: 'Complete A2 Grammar',
        deadline: DateTime.now().add(const Duration(days: 30)),
        targetProgress: 100,
        currentProgress: 65,
      ),
    ];

    _sessions = [
      GermanSession(
        id: 's1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationHours: 2,
        topicsCovered: 'Verbs with Dativ',
      ),
      GermanSession(
        id: 's2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        durationHours: 1.5,
        topicsCovered: 'Listening B1 level',
      ),
    ];

    notifyListeners();
  }

  void logSession(GermanSession session) async {
    _sessions.insert(0, session);
    _hoursLoggedThisWeek += session.durationHours;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('german_sessions')
          .doc(session.id)
          .set(session.toJson());
    } catch (e) {
      debugPrint('Error saving session to Firestore: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _germanLevel = data['germanLevel'] ?? 'A1';
        _germanClassFees = (data['germanClassFees'] ?? 250.0).toDouble();
        if (data['germanProgress'] != null) {
          _germanProgress = Map<String, String>.from(data['germanProgress']);
        }
      }

      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('german_sessions')
          .orderBy('date', descending: true)
          .get();

      if (sessionsSnapshot.docs.isNotEmpty) {
        _sessions = sessionsSnapshot.docs
            .map((d) => GermanSession.fromJson({...d.data(), 'id': d.id}))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching German data: $e');
    }
  }

  Future<void> updateGermanLevel(String level) async {
    _germanLevel = level;
    notifyListeners();
    await _firestore.collection('users').doc(_uid).set({
      'germanLevel': level,
    }, SetOptions(merge: true));
  }

  Future<void> updateLevelStatus(String level, String status) async {
    _germanProgress[level] = status;
    notifyListeners();
    await _firestore.collection('users').doc(_uid).set({
      'germanProgress': _germanProgress,
    }, SetOptions(merge: true));
  }

  void _scheduleGermanExamReminders() {
    final examDate = _examDates['A1'];
    if (examDate != null) {
      final now = DateTime.now();
      // Schedule for everyday until the exam at 6:30 PM
      for (int i = 0; i < 30; i++) {
        final reminderDate = DateTime(now.year, now.month, now.day + i, 18, 30);

        if (reminderDate.isAfter(now) && reminderDate.isBefore(examDate)) {
          NotificationService().scheduleNotification(
            id: 1000 + i,
            title: 'German A1 Exam Study!',
            body: 'Focus! Your exam is on 16th Feb. Review your vocabulary.',
            scheduledDate: reminderDate,
          );
        }
      }
    }
  }

  void updateGoal(String id, double progress) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index].currentProgress = progress;
      notifyListeners();
    }
  }

  // University Management
  Future<void> fetchUniversities() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .orderBy('name', descending: false)
          .get();

      _universities = snapshot.docs.map((doc) {
        return University.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching universities: $e');
    }
  }

  List<University> getUniversitiesByType(String type) {
    return _universities.where((uni) => uni.type == type).toList();
  }

  Future<void> addUniversity(University university) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(university.id)
          .set(university.toJson());

      _universities.add(university);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding university: $e');
    }
  }

  void updateGermanFees(double fees) async {
    _germanClassFees = fees;
    notifyListeners();
    await _firestore.collection('users').doc(_uid).set({
      'germanClassFees': fees,
    }, SetOptions(merge: true));
  }

  void updateExamDate(String level, DateTime date) {
    _examDates[level] = date;
    notifyListeners();
  }

  Future<void> updateUniversity(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(id)
          .update(updates);

      final index = _universities.indexWhere((uni) => uni.id == id);
      if (index != -1) {
        _universities[index] = University.fromJson({
          ..._universities[index].toJson(),
          ...updates,
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating university: $e');
    }
  }

  Future<void> deleteUniversity(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('universities')
          .doc(id)
          .delete();

      _universities.removeWhere((uni) => uni.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting university: $e');
    }
  }
}
