import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/student_os_models.dart';

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<WorkSession> _sessions = [];
  List<JobApplication> _applications = [];
  bool _isLoading = false;
  final double annualDayLimit = 140.0;

  List<WorkSession> get sessions => _sessions;
  List<JobApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get _uid => _auth.currentUser?.uid;

  JobProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final appSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('job_applications')
          .orderBy('appliedDate', descending: true)
          .get();

      _applications = appSnapshot.docs
          .map((doc) => JobApplication.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final sessionSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('work_sessions')
          .orderBy('date', descending: true)
          .get();

      _sessions = sessionSnapshot.docs
          .map((doc) => WorkSession.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching job data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addApplication(JobApplication app) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('job_applications')
          .add(app.toJson());

      _applications.insert(
        0,
        JobApplication(
          id: docRef.id,
          role: app.role,
          company: app.company,
          status: app.status,
          appliedDate: app.appliedDate,
          salaryRange: app.salaryRange,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding application: $e');
    }
  }

  Future<void> updateApplicationStatus(String id, String newStatus) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('job_applications')
          .doc(id)
          .update({'status': newStatus});

      final index = _applications.indexWhere((app) => app.id == id);
      if (index != -1) {
        final app = _applications[index];
        _applications[index] = JobApplication(
          id: app.id,
          role: app.role,
          company: app.company,
          status: newStatus,
          appliedDate: app.appliedDate,
          salaryRange: app.salaryRange,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating application status: $e');
    }
  }

  Future<void> addSession(WorkSession session) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('work_sessions')
          .add(session.toJson());

      _sessions.insert(
        0,
        WorkSession(
          id: docRef.id,
          date: session.date,
          hours: session.hours,
          company: session.company,
          isHoliday: session.isHoliday,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding session: $e');
    }
  }

  Future<void> deleteApplication(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('job_applications')
          .doc(id)
          .delete();
      _applications.removeWhere((app) => app.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting application: $e');
    }
  }

  Future<void> deleteSession(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('work_sessions')
          .doc(id)
          .delete();
      _sessions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }

  double get totalDaysWorked {
    return _sessions.fold(0.0, (sum, session) => sum + session.equivalentDays);
  }

  double get remainingDays => annualDayLimit - totalDaysWorked;

  double get usagePercentage =>
      (totalDaysWorked / annualDayLimit).clamp(0.0, 1.0);

  Map<String, double> get monthlyEarnings {
    Map<String, double> earnings = {};
    for (var session in _sessions) {
      String month = "${session.date.month}/${session.date.year}";
      // Mock calculation assuming 14.15 EUR/hour
      earnings[month] = (earnings[month] ?? 0) + (session.hours * 14.15);
    }
    return earnings;
  }
}
