class University {
  final String id;
  final String name;
  final String type; // 'Public' or 'Private'
  final String course;
  final String duration;
  final double tuitionFees;
  final String transportation;
  final List<String> requirements;
  final List<String> documents;
  final String
  status; // 'Applying', 'Interested', 'Applied', 'Accepted', 'Rejected'
  final String location;
  final String notes;

  University({
    required this.id,
    required this.name,
    required this.type,
    required this.course,
    required this.duration,
    required this.tuitionFees,
    this.transportation = '',
    this.requirements = const [],
    this.documents = const [],
    this.status = 'Interested',
    this.location = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'course': course,
    'duration': duration,
    'tuitionFees': tuitionFees,
    'transportation': transportation,
    'requirements': requirements,
    'documents': documents,
    'status': status,
    'location': location,
    'notes': notes,
  };

  factory University.fromJson(Map<String, dynamic> json) => University(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    course: json['course'],
    duration: json['duration'],
    tuitionFees: (json['tuitionFees'] as num).toDouble(),
    transportation: json['transportation'] ?? '',
    requirements: List<String>.from(json['requirements'] ?? []),
    documents: List<String>.from(json['documents'] ?? []),
    status: json['status'] ?? 'Interested',
    location: json['location'] ?? '',
    notes: json['notes'] ?? '',
  );
}
