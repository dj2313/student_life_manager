enum BureaucracyStatus { pending, inProgress, completed }

class BureaucracyTask {
  final String id;
  final String title;
  final String description;
  final BureaucracyStatus status;
  final String category;
  final DateTime? deadline;
  final List<String> requiredDocuments;

  BureaucracyTask({
    required this.id,
    required this.title,
    required this.description,
    this.status = BureaucracyStatus.pending,
    required this.category,
    this.deadline,
    this.requiredDocuments = const [],
  });

  BureaucracyTask copyWith({BureaucracyStatus? status, DateTime? deadline}) {
    return BureaucracyTask(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      category: category,
      deadline: deadline ?? this.deadline,
      requiredDocuments: requiredDocuments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.name,
    'category': category,
    'deadline': deadline?.toIso8601String(),
    'requiredDocuments': requiredDocuments,
  };

  factory BureaucracyTask.fromJson(Map<String, dynamic> json) =>
      BureaucracyTask(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: BureaucracyStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BureaucracyStatus.pending,
        ),
        category: json['category'],
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'])
            : null,
        requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      );
}

class WorkSession {
  final String id;
  final DateTime date;
  final double hours;
  final String company;
  final bool isHoliday;

  WorkSession({
    required this.id,
    required this.date,
    required this.hours,
    required this.company,
    this.isHoliday = false,
  });

  double get equivalentDays => hours > 4 ? 1.0 : 0.5;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'hours': hours,
    'company': company,
    'isHoliday': isHoliday,
  };

  factory WorkSession.fromJson(Map<String, dynamic> json) => WorkSession(
    id: json['id'],
    date: DateTime.parse(json['date']),
    hours: (json['hours'] as num).toDouble(),
    company: json['company'],
    isHoliday: json['isHoliday'] ?? false,
  );
}

class AcademicModule {
  final String id;
  final String name;
  final int ects;
  final double? grade;
  final String semester;
  final bool isCompleted;

  AcademicModule({
    required this.id,
    required this.name,
    required this.ects,
    this.grade,
    required this.semester,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ects': ects,
    'grade': grade,
    'semester': semester,
    'isCompleted': isCompleted,
  };

  factory AcademicModule.fromJson(Map<String, dynamic> json) => AcademicModule(
    id: json['id'],
    name: json['name'],
    ects: json['ects'],
    grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
    semester: json['semester'],
    isCompleted: json['isCompleted'] ?? false,
  );
}

class HousingApplication {
  final String id;
  final String title;
  final String platform;
  final String location;
  final double price;
  final String status;
  final DateTime appliedDate;
  final String? url;

  HousingApplication({
    required this.id,
    required this.title,
    required this.platform,
    required this.location,
    required this.price,
    this.status = 'Applied',
    required this.appliedDate,
    this.url,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'platform': platform,
    'location': location,
    'price': price,
    'status': status,
    'appliedDate': appliedDate.toIso8601String(),
    'url': url,
  };

  factory HousingApplication.fromJson(Map<String, dynamic> json) =>
      HousingApplication(
        id: json['id'],
        title: json['title'],
        platform: json['platform'],
        location: json['location'],
        price: (json['price'] as num).toDouble(),
        status: json['status'],
        appliedDate: DateTime.parse(json['appliedDate']),
        url: json['url'],
      );
}

class HousingDeposit {
  final String id;
  final double amount;
  final DateTime datePaid;
  final DateTime? expectedReturnType;
  final bool isReturned;
  final String propertyAddress;

  HousingDeposit({
    required this.id,
    required this.amount,
    required this.datePaid,
    this.expectedReturnType,
    this.isReturned = false,
    required this.propertyAddress,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'datePaid': datePaid.toIso8601String(),
    'expectedReturnType': expectedReturnType?.toIso8601String(),
    'isReturned': isReturned,
    'propertyAddress': propertyAddress,
  };

  factory HousingDeposit.fromJson(Map<String, dynamic> json) => HousingDeposit(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    datePaid: DateTime.parse(json['datePaid']),
    expectedReturnType: json['expectedReturnType'] != null
        ? DateTime.parse(json['expectedReturnType'])
        : null,
    isReturned: json['isReturned'] ?? false,
    propertyAddress: json['propertyAddress'],
  );
}

class AIResult {
  final String id;
  final String summary;
  final List<String> bulletPoints;
  final List<Flashcard> flashcards;
  final DateTime timestamp;

  AIResult({
    required this.id,
    required this.summary,
    required this.bulletPoints,
    required this.flashcards,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'summary': summary,
    'bulletPoints': bulletPoints,
    'flashcards': flashcards.map((f) => f.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };

  factory AIResult.fromJson(Map<String, dynamic> json) => AIResult(
    id: json['id'] ?? '',
    summary: json['summary'],
    bulletPoints: List<String>.from(json['bulletPoints'] ?? []),
    flashcards: (json['flashcards'] as List? ?? [])
        .map((f) => Flashcard.fromJson(f))
        .toList(),
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
  );
}

class Flashcard {
  final String front;
  final String back;

  Flashcard({required this.front, required this.back});

  Map<String, dynamic> toJson() => {'front': front, 'back': back};

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      Flashcard(front: json['front'], back: json['back']);
}
