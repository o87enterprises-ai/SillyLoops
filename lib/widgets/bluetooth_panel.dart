import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class BluetoothPanel extends StatelessWidget {
  const BluetoothPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return GestureDetector(
          onTap: () => _showBluetoothDialog(context, audioProvider),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: audioProvider.midiConnected
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: audioProvider.midiConnected
                    ? Colors.green
                    : Colors.white24,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth,
                  color: audioProvider.midiConnected
                      ? Colors.green
                      : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioProvider.midiConnected
                          ? audioProvider.midiDeviceName ?? 'Connected'
                          : 'Bluetooth',
                      style: TextStyle(
                        color: audioProvider.midiConnected
                            ? Colors.green
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      audioProvider.midiConnected
                          ? 'MIDI Device'
                          : 'Tap to connect',
                      style: TextStyle(
                        color: audioProvider.midiConnected
                            ? Colors.green.withOpacity(0.8)
                            : Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBluetoothDialog(BuildContext context, AudioProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Bluetooth MIDI',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (audioProvider.midiConnected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audioProvider.midiDeviceName ?? 'Connected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'MIDI Device',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        audioProvider.disconnectMidi();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              const ListTile(
                leading: Icon(Icons.search, color: Colors.white70),
                title: Text(
                  'Scan for Devices',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Tap to search for Bluetooth MIDI devices',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Make sure your MIDI device is in pairing mode',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          if (!audioProvider.midiConnected)
            TextButton(
              onPressed: () async {
                await audioProvider.connectMidi();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('SCAN'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
