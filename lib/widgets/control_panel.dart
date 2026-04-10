import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                    onTap: () => _showImportHelp(context),
                  ),
                  _ActionButton(
                    icon: Icons.mic,
                    label: 'Record',
                    onTap: () => _startRecording(context, audioProvider, sampleProvider),
                    isRecording: audioProvider.isRecording,
                  ),
                  _ActionButton(
                    icon: Icons.folder_open,
                    label: 'Load Pack',
                    onTap: () => _loadDefaultSamples(context, sampleProvider),
                  ),
                  _ActionButton(
                    icon: Icons.clear,
                    label: 'Clear',
                    onTap: () => _clearCurrentPad(context, sampleProvider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImportHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Long-press any pad to import a sample'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _clearCurrentPad(BuildContext context, SampleProvider sampleProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap a pad then press Clear'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadDefaultSamples(BuildContext context, SampleProvider sampleProvider) {
    sampleProvider.loadDefaultSamples();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default drum samples loaded to Bank A'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startRecording(
    BuildContext context,
    AudioProvider audioProvider,
    SampleProvider sampleProvider,
  ) async {
    if (audioProvider.isRecording) {
      // Stop recording
      final path = await audioProvider.stopRecording();
      if (context.mounted && path != null) {
        // Assign recording to current pad
        final padIndex = sampleProvider.numPads - 1; // Last pad by default
        sampleProvider.setSample(
          sampleProvider.currentBank,
          padIndex,
          SampleData(
            name: 'Recording ${DateTime.now().second}',
            path: path,
            isLoop: false,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording saved to pad!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Start recording
      final success = await audioProvider.startRecording(0);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording... Tap Record again to stop'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
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
                    : [Colors.red.shade400, Colors.red.shade700],
              ),
              boxShadow: [
                BoxShadow(
                  color: (audioProvider.isPlaying ? Colors.green : Colors.red)
                      .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
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
          'LOOP',
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
              Icons.loop,
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
