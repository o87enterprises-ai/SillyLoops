import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'sample_provider.dart';

class AudioProvider extends ChangeNotifier {
  final Map<String, AudioPlayer> _players = {};
  double _bpm = 120.0;
  bool _isPlaying = false;
  bool _loopMode = false;

  // Recording
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  double _inputLevel = 0.0;

  // MIDI
  bool _midiConnected = false;
  String? _midiDeviceName;

  double get bpm => _bpm;
  bool get isPlaying => _isPlaying;
  bool get loopMode => _loopMode;
  bool get isRecording => _isRecording;
  double get inputLevel => _inputLevel;
  bool get midiConnected => _midiConnected;
  String? get midiDeviceName => _midiDeviceName;

  void setBpm(double bpm) {
    _bpm = bpm;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setLoopMode(bool loopMode) {
    _loopMode = loopMode;
    notifyListeners();
  }

  // Recording functions
  Future<bool> requestMicPermission() async {
    if (Platform.isMacOS || Platform.isIOS) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } else if (Platform.isAndroid) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
    return false;
  }

  Future<bool> startRecording(int padIndex) async {
    if (!await requestMicPermission()) {
      return false;
    }

    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        _isRecording = true;
        notifyListeners();

        // Monitor input level
        _monitorInputLevel();
        return true;
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
    return false;
  }

  void _monitorInputLevel() async {
    while (_isRecording) {
      try {
        final level = await _recorder.getAmplitude();
        _inputLevel = level.current;
        notifyListeners();
      } catch (e) {
        // Ignore monitoring errors
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _inputLevel = 0.0;
      notifyListeners();
      return path ?? _recordingPath;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  void cancelRecording() async {
    try {
      await _recorder.stop();
      _isRecording = false;
      _inputLevel = 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Cancel recording error: $e');
    }
  }

  // MIDI functions
  Future<void> connectMidi() async {
    // MIDI connection would be handled via platform channels
    // This is a placeholder for the actual implementation
    _midiConnected = true;
    _midiDeviceName = 'Bluetooth MIDI Device';
    notifyListeners();
  }

  void disconnectMidi() {
    _midiConnected = false;
    _midiDeviceName = null;
    notifyListeners();
  }

  void sendMidiNote(int note, {int velocity = 127}) {
    if (!_midiConnected) return;
    // Send MIDI note via platform channel
    debugPrint('Sending MIDI note: $note, velocity: $velocity');
  }

  Future<void> playSample(String path, String playerId, {bool loop = false}) async {
    try {
      AudioPlayer? player = _players[playerId];
      
      if (player == null) {
        player = AudioPlayer();
        _players[playerId] = player;
      }

      if (player.source == null || player.source!.toString() != path) {
        await player.setSource(Source.uri(path));
      }

      player.loopMode = loop ? LoopMode.one : LoopMode.off;
      
      if (player.playerState.playing) {
        await player.stop();
        await player.seek(Duration.zero);
      }
      
      await player.play();
    } catch (e) {
      debugPrint('Error playing sample: $e');
    }
  }

  Future<void> stopSample(String playerId) async {
    final player = _players[playerId];
    if (player != null) {
      await player.stop();
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    if (_isRecording) {
      _recorder.stop();
    }
    _recorder.dispose();
    super.dispose();
  }
}
