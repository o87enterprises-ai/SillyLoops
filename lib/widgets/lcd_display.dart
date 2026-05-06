import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sample_provider.dart';
import '../providers/audio_provider.dart';

class LcdDisplay extends StatelessWidget {
  const LcdDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SampleProvider, AudioProvider>(
      builder: (context, sampleProvider, audioProvider, child) {
        bool isRecording = audioProvider.isRecording;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1929),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRecording ? Colors.red.shade700 : Colors.teal.shade700, 
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isRecording ? Colors.red : Colors.teal).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // LCD Screen icon
              Icon(
                isRecording ? Icons.mic : Icons.graphic_eq,
                color: isRecording ? Colors.red.shade400 : Colors.teal.shade400,
                size: 40,
              ),
              const SizedBox(width: 16),
              // Info display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LcdLabel(label: 'BANK'),
                        _LcdValue(
                          value: sampleProvider.getBankName(sampleProvider.currentBank),
                          color: Colors.teal.shade300,
                        ),
                        const SizedBox(width: 20),
                        _LcdLabel(label: 'PAD'),
                        _LcdValue(
                          value: sampleProvider.selectedPad == -1 
                              ? '--' 
                              : '${sampleProvider.selectedPad + 1}',
                          color: Colors.teal.shade300,
                        ),
                        const SizedBox(width: 20),
                        _LcdLabel(label: 'BPM'),
                        _LcdValue(
                          value: audioProvider.bpm.toInt().toString(),
                          color: Colors.teal.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _LcdLabel(label: 'STATUS'),
                        _LcdValue(
                          value: isRecording 
                              ? 'RECORDING' 
                              : audioProvider.isPlaying 
                                  ? 'PLAYING' 
                                  : 'READY',
                          color: isRecording 
                              ? Colors.red 
                              : audioProvider.isPlaying 
                                  ? Colors.green 
                                  : Colors.teal.shade300,
                          isBlinking: isRecording,
                        ),
                        const SizedBox(width: 20),
                        _LcdLabel(label: 'LOOP'),
                        _LcdValue(
                          value: audioProvider.loopMode ? 'ON' : 'OFF',
                          color: audioProvider.loopMode ? Colors.amber : Colors.teal.shade300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LcdLabel extends StatelessWidget {
  final String label;

  const _LcdLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}

class _LcdValue extends StatelessWidget {
  final String value;
  final Color color;
  final bool isBlinking;

  const _LcdValue({
    required this.value,
    required this.color,
    this.isBlinking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }
}
