import 'package:flutter/material.dart';
import '../../../data/models/student_os_models.dart';

class GPAProvider with ChangeNotifier {
  List<AcademicModule> _modules = [
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

  List<AcademicModule> get modules => _modules;

  void addModule(AcademicModule module) {
    _modules.add(module);
    notifyListeners();
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
