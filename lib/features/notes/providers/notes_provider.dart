import 'package:flutter/material.dart';
import '../../../data/models/note.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NotesProvider() {
    _loadMockData();
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
      Note(
        id: '2',
        title: 'Grocery List',
        content: 'Milk, Eggs, Bread, Butter, Coffee...',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['Personal'],
      ),
    ];
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
