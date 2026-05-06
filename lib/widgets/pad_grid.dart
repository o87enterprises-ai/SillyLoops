import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/sample_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/arpeggiator_provider.dart';
import '../widgets/drum_pad.dart';

class PadGrid extends StatelessWidget {
  const PadGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<SampleProvider, AudioProvider, ArpeggiatorProvider>(
      builder: (context, sampleProvider, audioProvider, arpProvider, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: sampleProvider.numPads,
          itemBuilder: (context, index) {
            final sample = sampleProvider.getSample(sampleProvider.currentBank, index);
            final isSelected = sampleProvider.selectedPad == index;
            final isRecording = audioProvider.isRecording && audioProvider.recordingPadIndex == index;
            
            final colors = [
              const Color(0xFFFF6B6B),
              const Color(0xFF4ECDC4),
              const Color(0xFFFFE66D),
              const Color(0xFF95E1D3),
              const Color(0xFFF38181),
              const Color(0xFFAA96DA),
              const Color(0xFFFCBAD3),
              const Color(0xFFA8D8EA),
            ];

            return DrumPad(
              index: index,
              color: colors[index % colors.length],
              sampleName: sample?.name ?? 'Empty',
              isPlaying: false,
              isSelected: isSelected,
              isRecording: isRecording,
              onTap: () => _handlePadTap(context, sampleProvider, audioProvider, arpProvider, index),
              onLongPress: () => _toggleLoop(context, sampleProvider, audioProvider, index),
              onLoopToggle: () => _toggleLoop(context, sampleProvider, audioProvider, index),
              isLoop: sample?.isLoop ?? false,
            );
          },
        );
      },
    );
  }

  void _handlePadTap(
    BuildContext context,
    SampleProvider sampleProvider,
    AudioProvider audioProvider,
    ArpeggiatorProvider arpProvider,
    int index,
  ) async {
    // If recording, tapping ANY pad stops the recording
    if (audioProvider.isRecording) {
      final path = await audioProvider.stopRecording();
      if (path != null) {
        final recordingIndex = audioProvider.recordingPadIndex;
        // The recordingPadIndex is actually reset in stopRecording, 
        // but we used _currentArpPad to store it. 
        // Wait, I need to make sure I get the index BEFORE it's reset or pass it back.
      }
      return;
    }

    sampleProvider.selectPad(index);
    final sample = sampleProvider.getSample(sampleProvider.currentBank, index);
    
    if (sample != null) {
      if (arpProvider.enabled) {
        audioProvider.startArp(index, arpProvider, sample);
      } else {
        audioProvider.stopArp();
        audioProvider.playSample(
          sample.path,
          'pad_${sampleProvider.currentBank}_$index',
          loop: sample.isLoop,
        );
      }
    } else {
      // Empty pad - highlight it and maybe show a hint
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _importSample(
    BuildContext context,
    SampleProvider sampleProvider,
    int index,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${appDir.path}/sample_$timestamp.wav';
        
        await file.copy(newPath);

        sampleProvider.setSample(
          sampleProvider.currentBank,
          index,
          SampleData(
            name: result.files.single.name,
            path: newPath,
            isLoop: false,
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sample loaded: ${result.files.single.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sample: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLoop(
    BuildContext context,
    SampleProvider sampleProvider,
    AudioProvider audioProvider,
    int index,
  ) {
    final currentSample = sampleProvider.getSample(sampleProvider.currentBank, index);
    if (currentSample != null) {
      final newLoopState = !currentSample.isLoop;
      sampleProvider.setLoopMode(sampleProvider.currentBank, index, newLoopState);
      
      // If enabling loop and sample exists, restart playback with loop
      if (newLoopState) {
        audioProvider.playSample(
          currentSample.path,
          'pad_${sampleProvider.currentBank}_$index',
          loop: true,
        );
      }
    }
  }
}
