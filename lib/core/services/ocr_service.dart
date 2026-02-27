import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    String fullText = recognizedText.text;

    // Extraction logic
    double amount = _extractAmount(fullText);
    String store = _extractStore(fullText);
    List<String> items = _extractPossibleItems(fullText);

    return {
      'store': store,
      'amount': amount,
      'category': _guessCategory(store, fullText),
      'items': items,
      'rawText': fullText,
    };
  }

  double _extractAmount(String text) {
    // Look for patterns like "TOTAL 23.45" or "SUMME 12,00"
    final RegExp amountRegExp = RegExp(
      r'(TOTAL|SUMME|GESAMT|AMOUNT|EUR|€)[\s:]*([0-9]+[.,][0-9]{2})',
      caseSensitive: false,
    );
    final matches = amountRegExp.allMatches(text);

    if (matches.isNotEmpty) {
      String amountStr = matches.last.group(2)!.replaceAll(',', '.');
      return double.tryParse(amountStr) ?? 0.0;
    }

    // Fallback: look for any price-like pattern and take the maximum found (often the total)
    final RegExp anyPrice = RegExp(r'[0-9]+[.,][0-9]{2}');
    final allPrices = anyPrice
        .allMatches(text)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '.')) ?? 0.0)
        .toList();

    if (allPrices.isNotEmpty) {
      allPrices.sort();
      return allPrices.last;
    }

    return 0.0;
  }

  String _extractStore(String text) {
    // First line is often the store name
    List<String> lines = text.split('\n');
    if (lines.isNotEmpty) {
      String firstLine = lines.first.trim();
      if (firstLine.length > 2) return firstLine;
    }
    return 'Unknown Store';
  }

  List<String> _extractPossibleItems(String text) {
    // Take items that look like products (usually lines with prices next to them)
    List<String> lines = text.split('\n');
    List<String> items = [];
    final RegExp priceOnLine = RegExp(r'[0-9]+[.,][0-9]{2}');

    for (var line in lines) {
      if (priceOnLine.hasMatch(line) && line.length > 10) {
        // Clean up common receipt noise
        String clean = line
            .replaceAll(priceOnLine, '')
            .replaceAll('*', '')
            .trim();
        if (clean.length > 3 &&
            !clean.contains('TOTAL') &&
            !clean.contains('SUMME')) {
          items.add(clean);
        }
      }
    }
    return items.take(5).toList();
  }

  String _guessCategory(String store, String text) {
    String lower = (store + text).toLowerCase();
    if (lower.contains('rewe') ||
        lower.contains('aldi') ||
        lower.contains('lidl') ||
        lower.contains('edeka') ||
        lower.contains('grocery')) {
      return 'Food';
    }
    if (lower.contains('db') ||
        lower.contains('bahn') ||
        lower.contains('uber') ||
        lower.contains('taxi')) {
      return 'Travel';
    }
    if (lower.contains('cinema') ||
        lower.contains('netflix') ||
        lower.contains('steam')) {
      return 'Entertainment';
    }
    return 'Misc';
  }

  void dispose() {
    _textRecognizer.close();
  }
}
