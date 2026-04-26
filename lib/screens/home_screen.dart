import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sample_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/pad_grid.dart';
import '../widgets/bank_selector.dart';
import '../widgets/control_panel.dart';
import '../widgets/lcd_display.dart';
import '../widgets/recording_panel.dart';
import '../widgets/bluetooth_panel.dart';
import '../widgets/arpeggiator_panel.dart';
import '../widgets/effects_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SILLYLOOPS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Row(
                      children: [
                        const BluetoothPanel(),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showSettings(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // LCD Display
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LcdDisplay(),
              ),
              
              const SizedBox(height: 12),
              
              // Recording Panel
              const RecordingPanel(),
              
              const SizedBox(height: 12),
              
              // Bank Selector
              const BankSelector(),
              
              const SizedBox(height: 8),
              
              const ArpeggiatorPanel(),
              
              const EffectsPanel(),
              
              const SizedBox(height: 8),
              
              // Pad Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const PadGrid(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Control Panel
              const ControlPanel(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.white),
              title: const Text('Load Sample Pack', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sample pack loading
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SillyLoops',
                  applicationVersion: '1.1.0',
                  applicationLegalese: 'Retro ARP Sampler',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
