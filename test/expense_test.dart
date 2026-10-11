import 'package:flutter_test/flutter_test.dart';
import 'package:student_life_manager/data/models/expense.dart';

void main() {
  group('Expense', () {
    test('toJson serializes all fields', () {
      final expense = Expense(
        id: 'e1',
        amount: 42.5,
        category: 'Groceries',
        date: DateTime.utc(2026, 10, 1),
        description: 'Weekly shop',
        currency: '€',
        notes: 'Lidl',
        isBlockedAccount: true,
      );

      final json = expense.toJson();

      expect(json['id'], 'e1');
      expect(json['amount'], 42.5);
      expect(json['category'], 'Groceries');
      expect(json['date'], '2026-10-01T00:00:00.000Z');
      expect(json['description'], 'Weekly shop');
      expect(json['currency'], '€');
      expect(json['notes'], 'Lidl');
      expect(json['isBlockedAccount'], true);
    });

    test('fromJson applies defaults for missing fields', () {
      final expense = Expense.fromJson({});

      expect(expense.id, '');
      expect(expense.amount, 0.0);
      expect(expense.category, 'Misc');
      expect(expense.description, '');
      expect(expense.currency, '€');
      expect(expense.notes, isNull);
      expect(expense.isBlockedAccount, false);
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = Expense(
        id: 'e2',
        amount: 956.0,
        category: 'Blocked Account',
        date: DateTime.utc(2026, 3, 1, 12),
        description: 'Sperrkonto payout',
        isBlockedAccount: true,
      );

      final restored = Expense.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.date, original.date);
      expect(restored.description, original.description);
      expect(restored.currency, original.currency);
      expect(restored.isBlockedAccount, original.isBlockedAccount);
    });
  });
}
