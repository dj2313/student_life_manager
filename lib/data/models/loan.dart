class Loan {
  late String id;
  late String personName;
  late double amount;
  late double remaining;
  late String status; // 'active' or 'completed'
  late DateTime dueDate;
  late DateTime createdAt;
  List<LoanPayment>? payments;

  Loan({
    required this.id,
    required this.personName,
    required this.amount,
    required this.remaining,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'remaining': remaining,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'payments': payments?.map((p) => p.toJson()).toList(),
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      personName: json['personName'],
      amount: json['amount'],
      remaining: json['remaining'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      payments: (json['payments'] as List?)
          ?.map((p) => LoanPayment.fromJson(p))
          .toList(),
    );
  }
}

class LoanPayment {
  late double amount;
  late DateTime date;
  String? notes;

  LoanPayment({required this.amount, required this.date, this.notes});

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'date': date.toIso8601String(), 'notes': notes};
  }

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}
