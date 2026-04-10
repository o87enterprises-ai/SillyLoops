import 'package:flutter/foundation.dart';

class SampleData {
  final String name;
  final String path;
  final bool isLoop;
  final double volume;

  SampleData({
    required this.name,
    required this.path,
    this.isLoop = false,
    this.volume = 1.0,
  });
}

class SampleProvider extends ChangeNotifier {
  int _currentBank = 0;
  final int _numBanks = 4;
  final int _numPads = 8;

  // 4 banks x 8 pads
  final List<List<SampleData?>> _samples = List.generate(
    4,
    (_) => List.generate(8, (_) => null),
  );

  // Default sample names for hip-hop drums
  final List<String> _defaultSampleNames = [
    'Kick',
    'Snare',
    'HiHat Closed',
    'HiHat Open',
    'Clap',
    'Percussion',
    'Crash',
    'Ride',
  ];

  int get currentBank => _currentBank;
  int get numBanks => _numBanks;
  int get numPads => _numPads;
  List<List<SampleData?>> get samples => _samples;
  SampleData? getSample(int bank, int pad) => _samples[bank][pad];

  String getBankName(int bank) {
    return 'Bank ${String.fromCharCode(65 + bank)}';
  }

  void setBank(int bank) {
    if (bank >= 0 && bank < _numBanks) {
      _currentBank = bank;
      notifyListeners();
    }
  }

  void nextBank() {
    _currentBank = (_currentBank + 1) % _numBanks;
    notifyListeners();
  }

  void previousBank() {
    _currentBank = (_currentBank - 1 + _numBanks) % _numBanks;
    notifyListeners();
  }

  void setSample(int bank, int pad, SampleData sample) {
    _samples[bank][pad] = sample;
    notifyListeners();
  }

  void clearSample(int bank, int pad) {
    _samples[bank][pad] = null;
    notifyListeners();
  }

  void setLoopMode(int bank, int pad, bool isLoop) {
    final sample = _samples[bank][pad];
    if (sample != null) {
      _samples[bank][pad] = SampleData(
        name: sample.name,
        path: sample.path,
        isLoop: isLoop,
        volume: sample.volume,
      );
      notifyListeners();
    }
  }

  void setVolume(int bank, int pad, double volume) {
    final sample = _samples[bank][pad];
    if (sample != null) {
      _samples[bank][pad] = SampleData(
        name: sample.name,
        path: sample.path,
        isLoop: sample.isLoop,
        volume: volume,
      );
      notifyListeners();
    }
  }

  void loadDefaultSamples() {
    for (int i = 0; i < _defaultSampleNames.length && i < _numPads; i++) {
      _samples[0][i] = SampleData(
        name: _defaultSampleNames[i],
        path: 'assets/samples/drum_$i.wav',
        isLoop: false,
      );
    }
    notifyListeners();
  }
}
