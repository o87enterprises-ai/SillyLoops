import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/audio_provider.dart';
import '../providers/sample_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, SampleProvider>(
      builder: (context, audioProvider, sampleProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // BPM Control
                  _BpmControl(audioProvider: audioProvider),
                  
                  // Play/Stop
                  _PlayStopButton(audioProvider: audioProvider),
                  
                  // Loop Mode Toggle
                  _LoopModeToggle(audioProvider: audioProvider),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quick actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.upload_file,
                    label: 'Import',
                    onTap: () => _handleImport(context, sampleProvider),
                    isActive: sampleProvider.selectedPad != -1,
                  ),
                  _ActionButton(
                    icon: audioProvider.isRecording ? Icons.stop : Icons.mic,
                    label: audioProvider.isRecording ? 'STOP' : 'RECORD',
                    onTap: () => _handleRecordPress(context, audioProvider, sampleProvider),
                    isRecording: audioProvider.isRecording,
                    isActive: sampleProvider.selectedPad != -1,
                  ),
                  _ActionButton(
                    icon: Icons.loop,
                    label: 'Loop',
                    onTap: () => _toggleLoopForSelected(context, sampleProvider, audioProvider),
                    isActive: sampleProvider.selectedPad != -1 && 
                             sampleProvider.getSample(sampleProvider.currentBank, sampleProvider.selectedPad) != null,
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Clear',
                    onTap: () => _clearSelectedPad(context, sampleProvider),
                    isActive: sampleProvider.selectedPad != -1,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImport(BuildContext context, SampleProvider sampleProvider) async {
    final selectedPad = sampleProvider.selectedPad;
    if (selectedPad == -1) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = result.files.single.name;
        final newPath = '${appDir.path}/imported_$timestamp.wav';
        
        await file.copy(newPath);

        sampleProvider.setSample(
          sampleProvider.currentBank,
          selectedPad,
          SampleData(
            name: fileName,
            path: newPath,
            isLoop: true,
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLoopForSelected(BuildContext context, SampleProvider sampleProvider, AudioProvider audioProvider) {
    final selectedPad = sampleProvider.selectedPad;
    if (selectedPad != -1) {
      final sample = sampleProvider.getSample(sampleProvider.currentBank, selectedPad);
      if (sample != null) {
        final newLoop = !sample.isLoop;
        sampleProvider.setLoopMode(sampleProvider.currentBank, selectedPad, newLoop);
        
        if (newLoop) {
          audioProvider.playSample(sample.path, 'pad_${sampleProvider.currentBank}_$selectedPad', loop: true);
        } else {
          audioProvider.stopSample('pad_${sampleProvider.currentBank}_$selectedPad');
        }
      }
    }
  }

  void _clearSelectedPad(BuildContext context, SampleProvider sampleProvider) {
    final selectedPad = sampleProvider.selectedPad;
    if (selectedPad != -1) {
      sampleProvider.clearSample(sampleProvider.currentBank, selectedPad);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pad ${selectedPad + 1} cleared'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleRecordPress(
    BuildContext context,
    AudioProvider audioProvider,
    SampleProvider sampleProvider,
  ) async {
    if (audioProvider.isRecording) {
      final recordingIndex = audioProvider.recordingPadIndex;
      final path = await audioProvider.stopRecording();
      
      if (context.mounted && path != null && recordingIndex != -1) {
        sampleProvider.setSample(
          sampleProvider.currentBank,
          recordingIndex,
          SampleData(
            name: 'Recording ${DateTime.now().hour}:${DateTime.now().minute}',
            path: path,
            isLoop: true, // Default to loop for looper feel
          ),
        );
        
        // Auto-play the loop immediately
        audioProvider.playSample(
          path, 
          'pad_${sampleProvider.currentBank}_$recordingIndex',
          loop: true
        );
      }
    } else {
      final selectedPad = sampleProvider.selectedPad;
      if (selectedPad == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select a pad first!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await audioProvider.startRecording(selectedPad);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BpmControl extends StatefulWidget {
  final AudioProvider audioProvider;

  const _BpmControl({required this.audioProvider});

  @override
  State<_BpmControl> createState() => _BpmControlState();
}

class _BpmControlState extends State<_BpmControl> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'BPM',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () => widget.audioProvider.setBpm(
                (widget.audioProvider.bpm - 5).clamp(60, 200),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                widget.audioProvider.bpm.toInt().toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => widget.audioProvider.setBpm(
                (widget.audioProvider.bpm + 5).clamp(60, 200),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayStopButton extends StatelessWidget {
  final AudioProvider audioProvider;

  const _PlayStopButton({required this.audioProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'TRANSPORT',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => audioProvider.togglePlay(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: audioProvider.isPlaying
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.white12, Colors.white24],
              ),
              boxShadow: audioProvider.isPlaying ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ] : null,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              audioProvider.isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoopModeToggle extends StatelessWidget {
  final AudioProvider audioProvider;

  const _LoopModeToggle({required this.audioProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'MASTER LOOP',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => audioProvider.setLoopMode(!audioProvider.loopMode),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: audioProvider.loopMode ? Colors.blue : Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: audioProvider.loopMode ? Colors.white : Colors.white24,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.all_inclusive,
              color: audioProvider.loopMode ? Colors.white : Colors.white38,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRecording;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRecording = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.3,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRecording ? Colors.red.withOpacity(0.5) : Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRecording ? Colors.red : Colors.white24,
                  width: isRecording ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isRecording ? Colors.white : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isRecording ? Colors.red : Colors.white70,
                fontSize: 10,
                fontWeight: isRecording ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
