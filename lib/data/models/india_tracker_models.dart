class IndiaItem {
  final String id;
  final String name;
  final String category; // 'Clothes', 'Food', 'Electronics', 'Gifts', etc.
  final int quantity;
  final double valueInr;
  final double valueEur;

  IndiaItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.valueInr,
    required this.valueEur,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'valueInr': valueInr,
      'valueEur': valueEur,
    };
  }

  factory IndiaItem.fromJson(Map<String, dynamic> json) {
    return IndiaItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      valueInr: (json['valueInr'] as num).toDouble(),
      valueEur: (json['valueEur'] as num).toDouble(),
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
