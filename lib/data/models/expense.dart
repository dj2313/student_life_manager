class Expense {
  late String id;
  late double amount;
  late String category;
  late DateTime date;
  late String description;
  late String currency;
  String? notes;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.currency = '€',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'currency': currency,
      'notes': notes,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      currency: json['currency'] ?? '€',
      notes: json['notes'],
    );
  }
}
