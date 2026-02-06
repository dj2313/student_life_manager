import 'package:flutter/material.dart';
import '../../../data/models/student_os_models.dart';

class JobProvider with ChangeNotifier {
  final List<WorkSession> _sessions = [];
  final List<JobApplication> _applications = [];
  final double annualDayLimit = 140.0; // German student visa limit

  List<WorkSession> get sessions => _sessions;
  List<JobApplication> get applications => _applications;

  void addApplication(JobApplication app) {
    _applications.add(app);
    notifyListeners();
  }

  void updateApplicationStatus(String id, String newStatus) {
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
  }

  void addSession(WorkSession session) {
    _sessions.add(session);
    notifyListeners();
  }

  double get totalDaysWorked {
    return _sessions.fold(0.0, (sum, session) => sum + session.equivalentDays);
  }

  double get remainingDays => annualDayLimit - totalDaysWorked;

  double get usagePercentage =>
      (totalDaysWorked / annualDayLimit).clamp(0.0, 1.0);

  Map<String, double> get monthlyEarnings {
    // Mock calculation assuming 14 EUR/hour
    Map<String, double> earnings = {};
    for (var session in _sessions) {
      String month = "${session.date.month}/${session.date.year}";
      earnings[month] = (earnings[month] ?? 0) + (session.hours * 14.15);
    }
    return earnings;
  }
}
