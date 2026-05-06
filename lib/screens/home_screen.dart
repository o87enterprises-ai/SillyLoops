import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sample_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/session_provider.dart';
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
              'Menu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.greenAccent),
              title: const Text('Save Session', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSaveDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special, color: Colors.amberAccent),
              title: const Text('My Sessions', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showLoadDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SillyLoops',
                  applicationVersion: '1.2.0',
                  applicationLegalese: 'Traditional Sampler & Looper',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Save Current State', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Session Name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final sampleProvider = Provider.of<SampleProvider>(context, listen: false);
                final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                Provider.of<SessionProvider>(context, listen: false)
                    .saveSession(name, sampleProvider, audioProvider.bpm);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Session "$name" saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showLoadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      isScrollControlled: true,
      builder: (context) => Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          if (sessionProvider.sessions.isEmpty) {
            return Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text('No saved sessions.', style: TextStyle(color: Colors.white54)),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saved Sessions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: sessionProvider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessionProvider.sessions[index];
                      return ListTile(
                        leading: const Icon(Icons.album, color: Colors.purpleAccent),
                        title: Text(session.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${session.createdAt.day}/${session.createdAt.month} ${session.bpm.toInt()} BPM',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => sessionProvider.deleteSession(session.id),
                        ),
                        onTap: () {
                          final sampleProvider = Provider.of<SampleProvider>(context, listen: false);
                          final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                          sessionProvider.loadSessionIntoApp(session, sampleProvider);
                          audioProvider.setBpm(session.bpm);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Loaded session: ${session.name}'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
