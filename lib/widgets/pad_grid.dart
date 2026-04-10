import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/sample_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/drum_pad.dart';

class PadGrid extends StatelessWidget {
  const PadGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SampleProvider, AudioProvider>(
      builder: (context, sampleProvider, audioProvider, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: sampleProvider.numPads,
          itemBuilder: (context, index) {
            final sample = sampleProvider.getSample(sampleProvider.currentBank, index);
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
              color: colors[index],
              sampleName: sample?.name ?? 'Pad ${index + 1}',
              isPlaying: false,
              onTap: () => _playPad(context, sampleProvider, audioProvider, index),
              onLongPress: () => _importSample(context, sampleProvider, index),
              onLoopToggle: () => _toggleLoop(context, sampleProvider, audioProvider, index),
              isLoop: sample?.isLoop ?? false,
            );
          },
        );
      },
    );
  }

  void _playPad(
    BuildContext context,
    SampleProvider sampleProvider,
    AudioProvider audioProvider,
    int index,
  ) {
    final sample = sampleProvider.getSample(sampleProvider.currentBank, index);
    if (sample != null) {
      audioProvider.playSample(
        sample.path,
        'pad_${sampleProvider.currentBank}_$index',
        loop: sample.isLoop,
      );
    } else {
      // Haptic feedback for empty pad
      Feedback.forLongPress(context);
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
