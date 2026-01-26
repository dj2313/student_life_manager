import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/note.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  String get _uid => _auth.currentUser?.uid ?? 'guest_user';

  NotesProvider() {
    // Ensuring the platform channel is ready before calling Firebase
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await fetchNotes();
    } catch (e) {
      debugPrint('NotesProvider Initialization Error: $e');
      _loadMockData();
    }
  }

  Future<void> fetchNotes() async {
    if (_uid == 'guest_user' && _auth.currentUser == null) {
      // If still not authenticated, wait or try again later
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('notes')
          .orderBy('updatedAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _notes = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Note.fromJson(data);
        }).toList();
      } else {
        // If no data in Firestore, maybe don't load mock data here
        // to avoid confusing the user. Just keep _notes empty.
        _notes = [];
      }
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      // Only load mock data if we really have nothing
      if (_notes.isEmpty) _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockData() {
    _notes = [
      Note(
        id: '1',
        title: 'Interview Tips',
        content: 'Dress professionally, prepare questions, research company...',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Career', 'Berlin'],
      ),
    ];
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    try {
      // Use Firestore set to ensure it's saved with our ID
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('notes')
          .doc(note.id)
          .set(note.toJson());

      // Update local list
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index == -1) {
        _notes.insert(0, note);
      } else {
        _notes[index] = note;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> updateNote(Note updatedNote) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('notes')
          .doc(updatedNote.id)
          .update(updatedNote.toJson());

      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('notes')
          .doc(id)
          .delete();

      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
}
