// No material dependency needed for pure logic service

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Mock AI summarizer to avoid external API costs initially
  Future<List<String>> summarizeNote(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      'Core concept identified: Student Life Management',
      'Actionable item regarding bureaucracy tasks',
      'Financial goals for the current semester',
      'Academic progress toward the degree requirements',
      'Integration with German administrative workflows',
    ];
  }

  /// Mock flashcard generator
  Future<List<Map<String, String>>> generateFlashcards(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'front': 'Anmeldung', 'back': 'City Registration in Germany'},
      {
        'front': 'Immatrikulationsbescheinigung',
        'back': 'Certificate of Enrollment',
      },
      {'front': 'Zulassungsbescheid', 'back': 'Letter of Admission'},
      {'front': 'WG (Wohngemeinschaft)', 'back': 'Shared Apartment'},
    ];
  }

  /// Specialized student translator
  String translateTerm(String term) {
    final Map<String, String> dictionary = {
      'immatrikulationsbescheinigung':
          'Certificate of Enrollment - Essential for your visa and student ID!',
      'zulassungsbescheid':
          'Letter of Admission - Your golden ticket to the university.',
      'aufenthaltstitel':
          'Residence Permit - The document allowing you to stay in Germany.',
      'wohnungsgeberbestätigung':
          'Rent Confirmation - Required for your city registration (Anmeldung).',
      'krankenkasse':
          'Health Insurance - Mandatory for all residents in Germany.',
      'semesterbeitrag':
          'Semester Fee - Includes your student ticket and admin costs.',
      'exmatrikulation':
          'De-registration - What happens when you finish or leave university.',
    };

    return dictionary[term.toLowerCase()] ??
        'Term not in student dictionary. Try a common administrative word!';
  }
}
