import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FocusTimerProvider with ChangeNotifier {
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  static const String _boxName = 'focus_timer_box';
  static const String _secondsKey = 'seconds_remaining';

  FocusTimerProvider() {
    _init();
  }

  Future<void> _init() async {
    final box = await Hive.openBox(_boxName);
    _secondsRemaining = box.get(_secondsKey, defaultValue: 25 * 60);
    notifyListeners();
  }

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        final box = await Hive.openBox(_boxName);
        await box.put(_secondsKey, _secondsRemaining);
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

  void resetTimer() async {
    stopTimer();
    _secondsRemaining = 25 * 60;
    final box = await Hive.openBox(_boxName);
    await box.put(_secondsKey, _secondsRemaining);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
