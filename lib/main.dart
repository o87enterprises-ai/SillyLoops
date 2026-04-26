import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/sample_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/arpeggiator_provider.dart';

void main() {
  runApp(const SillyLoopsApp());
}

class SillyLoopsApp extends StatelessWidget {
  const SillyLoopsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SampleProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => ArpeggiatorProvider()),
      ],
      child: MaterialApp(
        title: 'SillyLoops - Retro ARP Sampler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          fontFamily: 'RobotoMono',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
