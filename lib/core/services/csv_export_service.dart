import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/expense.dart';
import 'package:flutter/foundation.dart';

class CSVExportService {
  static Future<void> exportExpenses(List<Expense> expenses) async {
    try {
      String csv = 'Date,Description,Amount,Category,Blocked Account\n';

      for (final expense in expenses) {
        final date = DateFormat('yyyy-MM-dd HH:mm').format(expense.date);
        final description = expense.description.replaceAll(
          ',',
          ';',
        ); // Escape commas
        final amount = expense.amount.toStringAsFixed(2);
        final category = expense.category;
        final blocked = expense.isBlockedAccount ? 'Yes' : 'No';

        csv += '$date,$description,$amount,$category,$blocked\n';
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'StudentOS_Expenses_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Exported Financial Report');

      debugPrint('✅ CSV Exported successfully: ${file.path}');
    } catch (e) {
      debugPrint('❌ Error exporting CSV: $e');
      rethrow;
    }
  }
}
