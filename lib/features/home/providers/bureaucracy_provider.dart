import 'package:flutter/material.dart';
import '../../../data/models/student_os_models.dart';

class BureaucracyProvider with ChangeNotifier {
  List<BureaucracyTask> _tasks = [
    BureaucracyTask(
      id: '1',
      title: 'City Registration (Anmeldung)',
      description:
          'Register your address at the Burgeramt within 14 days of arrival.',
      category: 'Legal',
      requiredDocuments: [
        'Passport',
        'Rental Agreement (Wohnungsgeberbestätigung)',
      ],
    ),
    BureaucracyTask(
      id: '2',
      title: 'Health Insurance',
      description:
          'Activate your health insurance (TK, AOK, etc.) for enrollment.',
      category: 'Health',
      requiredDocuments: ['Passport', 'Zulassungsbescheinigung'],
    ),
    BureaucracyTask(
      id: '3',
      title: 'Residence Permit',
      description:
          'Apply for your study residence permit at the Ausländerbehörde.',
      category: 'Immigration',
      requiredDocuments: ['Proof of Funds', 'Insurance', 'Passport', 'Photos'],
    ),
    BureaucracyTask(
      id: '4',
      title: 'Bank Account / Blocked Account',
      description:
          'Activate your blocked account and open a local Sparkasse/N26 account.',
      category: 'Finance',
    ),
  ];

  List<BureaucracyTask> get tasks => _tasks;

  void updateTaskStatus(String id, BureaucracyStatus status) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status);
      notifyListeners();
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
