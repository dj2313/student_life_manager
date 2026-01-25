class Grocery {
  late String id;
  late List<GroceryItem> items;
  late double total;
  late DateTime date;
  late int weekNumber;

  double? budget;

  Grocery({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.weekNumber,
    this.budget,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
      'weekNumber': weekNumber,
      'budget': budget,
    };
  }

  factory Grocery.fromJson(Map<String, dynamic> json) {
    return Grocery(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => GroceryItem.fromJson(item))
          .toList(),
      total: json['total'],
      date: DateTime.parse(json['date']),
      weekNumber: json['weekNumber'],
      budget: json['budget'],
    );
  }
}

class GroceryItem {
  late String name;
  late double price;
  int? quantity;

  GroceryItem({required this.name, required this.price, this.quantity});

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}
