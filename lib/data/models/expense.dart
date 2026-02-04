class Expense {
  late String id;
  late double amount;
  late String category;
  late DateTime date;
  late String description;
  late String currency;
  String? notes;
  bool isBlockedAccount;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.currency = '€',
    this.notes,
    this.isBlockedAccount = false,
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
      'isBlockedAccount': isBlockedAccount,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'Misc',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      currency: json['currency'] ?? '€',
      notes: json['notes'],
      isBlockedAccount: json['isBlockedAccount'] ?? false,
    );
  }
}
