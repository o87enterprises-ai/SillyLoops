import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'sample_provider.dart';
import 'arpeggiator_provider.dart';

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
  Duration _recordingDuration = Duration.zero;

  // Arpeggiator
  Timer? _arpTimer;
  int _arpStep = 0;
  int _currentArpPad = -1;

  // Scale intervals
  final Map<ArpScale, List<int>> _scales = {
    ArpScale.chromatic: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    ArpScale.major: [0, 2, 4, 5, 7, 9, 11],
    ArpScale.minor: [0, 2, 3, 5, 7, 8, 10],
    ArpScale.pentatonic: [0, 2, 4, 7, 9],
  };

  // MIDI
  bool _midiConnected = false;
  String? _midiDeviceName;

  double get bpm => _bpm;
  bool get isPlaying => _isPlaying;
  bool get loopMode => _loopMode;
  bool get isRecording => _isRecording;
  double get inputLevel => _inputLevel;
  Duration get recordingDuration => _recordingDuration;
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
        _recordingDuration = Duration.zero;
        notifyListeners();

        // Monitor input level and duration
        _monitorRecording();
        return true;
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
    return false;
  }

  void _monitorRecording() async {
    final startTime = DateTime.now();
    while (_isRecording) {
      try {
        final level = await _recorder.getAmplitude();
        _inputLevel = level.current;
        _recordingDuration = DateTime.now().difference(startTime);
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

  Future<void> playSample(String path, String playerId, {bool loop = false, double pitch = 1.0}) async {
    try {
      AudioPlayer? player = _players[playerId];
      
      if (player == null) {
        player = AudioPlayer();
        _players[playerId] = player;
      }

      // Handle both assets and files
      if (player.audioSource == null || !player.audioSource!.toString().contains(path)) {
        if (path.startsWith('assets/')) {
          await player.setAsset(path);
        } else {
          await player.setFilePath(path);
        }
      }

      await player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await player.setPitch(pitch);
      await player.setSpeed(pitch); // Linking pitch and speed for retro feel
      
      if (player.playing) {
        await player.stop();
        await player.seek(Duration.zero);
      }
      
      player.play();
    } catch (e) {
      debugPrint('Error playing sample ($path): $e');
    }
  }

  Future<void> stopSample(String playerId) async {
    final player = _players[playerId];
    if (player != null) {
      await player.stop();
    }
  }

  void stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
    _isPlaying = false;
    stopArp();
    notifyListeners();
  }

  // Arpeggiator methods
  void startArp(int padIndex, ArpeggiatorProvider arpProvider, SampleData sample) {
    if (_arpTimer != null && _currentArpPad == padIndex) return;
    
    stopArp();
    _currentArpPad = padIndex;
    
    // Calculate interval based on BPM and ArpRate
    // BPM = beats per minute. 1 beat = 1/4 note.
    // 60000 / BPM = ms per 1/4 note.
    final msPerQuarter = 60000 / _bpm;
    
    double multiplier = 1.0;
    switch (arpProvider.rate) {
      case ArpRate.rate1_4: multiplier = 1.0; break;
      case ArpRate.rate1_8: multiplier = 0.5; break;
      case ArpRate.rate1_16: multiplier = 0.25; break;
      case ArpRate.rate1_32: multiplier = 0.125; break;
    }
    
    final intervalMs = (msPerQuarter * multiplier).toInt();
    
    _arpTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying || !arpProvider.enabled || _currentArpPad != padIndex) {
        timer.cancel();
        return;
      }

      final note = _getNextArpNote(arpProvider);
      final pitch = math.pow(2.0, (note - 60) / 12.0).toDouble();
      
      playSample(
        sample.path, 
        'arp_$padIndex', 
        loop: false,
        pitch: pitch,
      );
      
      _arpStep++;
    });
  }

  int _getNextArpNote(ArpeggiatorProvider arpProvider) {
    final scaleNotes = _scales[arpProvider.scale] ?? _scales[ArpScale.major]!;
    final octaves = arpProvider.octaves;
    final totalNotes = scaleNotes.length * octaves;
    
    int index = 0;
    switch (arpProvider.mode) {
      case ArpMode.up:
        index = _arpStep % totalNotes;
        break;
      case ArpMode.down:
        index = (totalNotes - 1) - (_arpStep % totalNotes);
        break;
      case ArpMode.upDown:
        final cycle = totalNotes * 2 - 2;
        if (cycle <= 0) {
          index = 0;
        } else {
          final step = _arpStep % cycle;
          index = step < totalNotes ? step : cycle - step;
        }
        break;
      case ArpMode.random:
        index = math.Random().nextInt(totalNotes);
        break;
    }
    
    final octaveOffset = (index / scaleNotes.length).floor();
    final noteInScale = index % scaleNotes.length;
    
    return 60 + scaleNotes[noteInScale] + (octaveOffset * 12);
  }

  void stopArp() {
    _arpTimer?.cancel();
    _arpTimer = null;
    _arpStep = 0;
    _currentArpPad = -1;
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
