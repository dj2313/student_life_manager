import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SystemStatusProvider with ChangeNotifier {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  ConnectivityResult get connectivityResult => _connectivityResult;

  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SystemStatusProvider() {
    _init();
  }

  Future<void> _init() async {
    // Initial values
    _batteryLevel = await _battery.batteryLevel;

    // Connectivity plus 6.x+ returns a List<ConnectivityResult>
    final results = await _connectivity.checkConnectivity();
    _connectivityResult = results.isNotEmpty
        ? results.first
        : ConnectivityResult.none;

    // Listeners
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _batteryState = state;
      _updateBatteryLevel();
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _connectivityResult = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      notifyListeners();
    });

    // Periodic battery level update
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateBatteryLevel();
    });
  }

  Future<void> _updateBatteryLevel() async {
    final level = await _battery.batteryLevel;
    if (_batteryLevel != level) {
      _batteryLevel = level;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
