import 'package:flutter/foundation.dart';
import 'dart:async';

enum ArpMode {
  up,
  down,
  upDown,
  random,
}

enum ArpRate {
  rate1_4,
  rate1_8,
  rate1_16,
  rate1_32,
}

enum ArpScale {
  chromatic,
  major,
  minor,
  pentatonic,
}

class ArpeggiatorProvider extends ChangeNotifier {
  bool _enabled = false;
  ArpMode _mode = ArpMode.up;
  ArpRate _rate = ArpRate.rate1_16;
  ArpScale _scale = ArpScale.major;
  int _octaves = 1;
  
  Timer? _timer;
  int _currentStep = 0;
  List<int> _activePads = [];

  bool get enabled => _enabled;
  ArpMode get mode => _mode;
  ArpRate get rate => _rate;
  ArpScale get scale => _scale;
  int get octaves => _octaves;

  void setEnabled(bool value) {
    _enabled = value;
    if (!_enabled) {
      _stopArp();
    }
    notifyListeners();
  }

  void setMode(ArpMode value) {
    _mode = value;
    notifyListeners();
  }

  void setRate(ArpRate value) {
    _rate = value;
    notifyListeners();
  }

  void setScale(ArpScale value) {
    _scale = value;
    notifyListeners();
  }

  void setOctaves(int value) {
    _octaves = value;
    notifyListeners();
  }

  void _stopArp() {
    _timer?.cancel();
    _timer = null;
    _currentStep = 0;
  }

  double get rateValue {
    switch (_rate) {
      case ArpRate.rate1_4: return 1/4;
      case ArpRate.rate1_8: return 1/8;
      case ArpRate.rate1_16: return 1/16;
      case ArpRate.rate1_32: return 1/32;
    }
  }

  // This will be called by the AudioProvider or UI to sync with BPM
  void updateBpm(double bpm) {
    if (_enabled && _timer != null) {
      _stopArp();
      // Restart with new timing if needed
    }
  }
}
