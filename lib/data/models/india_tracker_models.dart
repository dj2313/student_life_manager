class IndiaItem {
  final String id;
  final String name;
  final String category; // 'Clothes', 'Food', 'Electronics', 'Gifts', etc.
  final int quantity;
  final double valueInr;
  final double valueEur;
  final DateTime date;

  IndiaItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.valueInr,
    required this.valueEur,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'valueInr': valueInr,
      'valueEur': valueEur,
      'date': date.toIso8601String(),
    };
  }

  factory IndiaItem.fromJson(Map<String, dynamic> json) {
    return IndiaItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'] ?? 1,
      valueInr: (json['valueInr'] as num).toDouble(),
      valueEur: (json['valueEur'] as num).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}

class IndiaTravelExpense {
  final String id;
  final String title;
  final String description;
  final double amountInr;
  final double amountEur;
  final DateTime date;
  final String type; // 'Flight', 'Visa', 'Insurance', 'Setup', etc.

  IndiaTravelExpense({
    required this.id,
    required this.title,
    required this.description,
    required this.amountInr,
    required this.amountEur,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amountInr': amountInr,
      'amountEur': amountEur,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory IndiaTravelExpense.fromJson(Map<String, dynamic> json) {
    return IndiaTravelExpense(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amountInr: (json['amountInr'] as num).toDouble(),
      amountEur: (json['amountEur'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }
}
