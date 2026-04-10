import 'package:flutter/services.dart';

/// Platform channel interface for JUCE audio engine
class AudioEngineChannel {
  static const MethodChannel _channel = MethodChannel('com.samplebeat/audio_engine');

  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print('Failed to initialize audio engine: ${e.message}');
    }
  }

  static Future<void> playPad(int index) async {
    try {
      await _channel.invokeMethod('playPad', {'index': index});
    } on PlatformException catch (e) {
      print('Failed to play pad: ${e.message}');
    }
  }

  static Future<void> stopPad(int index) async {
    try {
      await _channel.invokeMethod('stopPad', {'index': index});
    } on PlatformException catch (e) {
      print('Failed to stop pad: ${e.message}');
    }
  }

  static Future<void> stopAll() async {
    try {
      await _channel.invokeMethod('stopAll');
    } on PlatformException catch (e) {
      print('Failed to stop all: ${e.message}');
    }
  }

  static Future<void> loadSample(int index, String path) async {
    try {
      await _channel.invokeMethod('loadSample', {
        'index': index,
        'path': path,
      });
    } on PlatformException catch (e) {
      print('Failed to load sample: ${e.message}');
    }
  }

  static Future<void> setBpm(double bpm) async {
    try {
      await _channel.invokeMethod('setBpm', {'bpm': bpm});
    } on PlatformException catch (e) {
      print('Failed to set BPM: ${e.message}');
    }
  }

  static Future<void> setLoopMode(int index, bool loop) async {
    try {
      await _channel.invokeMethod('setLoopMode', {
        'index': index,
        'loop': loop,
      });
    } on PlatformException catch (e) {
      print('Failed to set loop mode: ${e.message}');
    }
  }

  static Future<void> setVolume(int index, double volume) async {
    try {
      await _channel.invokeMethod('setVolume', {
        'index': index,
        'volume': volume,
      });
    } on PlatformException catch (e) {
      print('Failed to set volume: ${e.message}');
    }
  }

  static Future<void> clearPad(int index) async {
    try {
      await _channel.invokeMethod('clearPad', {'index': index});
    } on PlatformException catch (e) {
      print('Failed to clear pad: ${e.message}');
    }
  }

  static Future<void> setReverb(double amount) async {
    try {
      await _channel.invokeMethod('setReverb', {'amount': amount});
    } on PlatformException catch (e) {
      print('Failed to set reverb: ${e.message}');
    }
  }

  static Future<void> setDelay(double time, double feedback) async {
    try {
      await _channel.invokeMethod('setDelay', {
        'time': time,
        'feedback': feedback,
      });
    } on PlatformException catch (e) {
      print('Failed to set delay: ${e.message}');
    }
  }
}
