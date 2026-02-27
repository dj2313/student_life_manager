class Subscription {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime nextRenewal;
  final String frequency; // 'Monthly', 'Yearly'
  final bool isActive;
  final String? notes;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.nextRenewal,
    this.frequency = 'Monthly',
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'nextRenewal': nextRenewal.toIso8601String(),
      'frequency': frequency,
      'isActive': isActive,
      'notes': notes,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'Entertainment',
      nextRenewal: DateTime.parse(
        json['nextRenewal'] ?? DateTime.now().toIso8601String(),
      ),
      frequency: json['frequency'] ?? 'Monthly',
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
    );
  }
}
