import 'dart:async';
import 'package:flutter/material.dart';

class FocusTimerProvider with ChangeNotifier {
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;

  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;

  double get progress => (25 * 60 - _secondsRemaining) / (25 * 60);

  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        stopTimer();
      }
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _secondsRemaining = 25 * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
