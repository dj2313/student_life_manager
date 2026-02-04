import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/student_os_models.dart';

class StudyAssistantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AIResult> _history = [];
  List<AIResult> get history => _history;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  StudyAssistantProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('ai_results')
          .orderBy('timestamp', descending: true)
          .get();

      _history = snapshot.docs
          .map((d) => AIResult.fromJson({...d.data(), 'id': d.id}))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching AI history: $e');
    }
  }

  Future<void> saveResult(AIResult result) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('ai_results')
          .add(result.toJson());

      _history.insert(
        0,
        AIResult(
          id: docRef.id,
          summary: result.summary,
          bulletPoints: result.bulletPoints,
          flashcards: result.flashcards,
          timestamp: result.timestamp,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving AI result: $e');
    }
  }

  Future<void> deleteResult(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('ai_results')
          .doc(id)
          .delete();

      _history.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting AI result: $e');
    }
  }
}
