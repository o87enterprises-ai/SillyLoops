import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/sample_provider.dart';

class RecordingPanel extends StatelessWidget {
  const RecordingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        if (!audioProvider.isRecording) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade400, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Input Level Meter
                  Column(
                    children: [
                      const Text(
                        'INPUT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        height: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (audioProvider.inputLevel + 60) / 60,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                            minHeight: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${audioProvider.inputLevel.toStringAsFixed(1)} dB',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Record Button
                  GestureDetector(
                    onTap: () => _stopRecording(context, audioProvider),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade700],
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop, color: Colors.white, size: 28),
                          SizedBox(height: 2),
                          Text(
                            'STOP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Timer
                  Column(
                    children: [
                      const Text(
                        'TIME',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '0.0s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _stopRecording(BuildContext context, AudioProvider audioProvider) async {
    final path = await audioProvider.stopRecording();
    if (context.mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording saved: $path'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
