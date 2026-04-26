import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../services/audio_engine_channel.dart';

class EffectsPanel extends StatefulWidget {
  const EffectsPanel({super.key});

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel> {
  double _reverb = 0.0;
  double _delayTime = 0.5;
  double _delayFeedback = 0.3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.waves, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'EFFECTS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _EffectSlider(
            label: 'REVERB',
            value: _reverb,
            onChanged: (val) {
              setState(() => _reverb = val);
              AudioEngineChannel.setReverb(val);
            },
          ),
          const SizedBox(height: 12),
          _EffectSlider(
            label: 'DELAY TIME',
            value: _delayTime,
            onChanged: (val) {
              setState(() => _delayTime = val);
              AudioEngineChannel.setDelay(_delayTime, _delayFeedback);
            },
          ),
          const SizedBox(height: 12),
          _EffectSlider(
            label: 'DELAY FEEDBACK',
            value: _delayFeedback,
            onChanged: (val) {
              setState(() => _delayFeedback = val);
              AudioEngineChannel.setDelay(_delayTime, _delayFeedback);
            },
          ),
        ],
      ),
    );
  }
}

class _EffectSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _EffectSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontFamily: 'monospace'),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orangeAccent,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.orangeAccent,
            overlayColor: Colors.orangeAccent.withOpacity(0.2),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
