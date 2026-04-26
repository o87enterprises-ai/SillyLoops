import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/arpeggiator_provider.dart';

class ArpeggiatorPanel extends StatelessWidget {
  const ArpeggiatorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArpeggiatorProvider>(
      builder: (context, arpProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: arpProvider.enabled ? Colors.purple.shade400 : Colors.white10,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: arpProvider.enabled ? Colors.purple.shade300 : Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ARPEGGIATOR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: arpProvider.enabled,
                    onChanged: (value) => arpProvider.setEnabled(value),
                    activeColor: Colors.purple.shade400,
                  ),
                ],
              ),
              if (arpProvider.enabled) ...[
                const Divider(color: Colors.white10, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ArpOption(
                      label: 'MODE',
                      value: arpProvider.mode.name.toUpperCase(),
                      onTap: () => _showModePicker(context, arpProvider),
                    ),
                    _ArpOption(
                      label: 'RATE',
                      value: _getRateLabel(arpProvider.rate),
                      onTap: () => _showRatePicker(context, arpProvider),
                    ),
                    _ArpOption(
                      label: 'SCALE',
                      value: arpProvider.scale.name.toUpperCase(),
                      onTap: () => _showScalePicker(context, arpProvider),
                    ),
                    _ArpOption(
                      label: 'OCT',
                      value: '${arpProvider.octaves}',
                      onTap: () {
                        final nextOct = (arpProvider.octaves % 3) + 1;
                        arpProvider.setOctaves(nextOct);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showScalePicker(BuildContext context, ArpeggiatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ArpScale.values.map((scale) => ListTile(
          title: Text(scale.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
          onTap: () {
            provider.setScale(scale);
            Navigator.pop(context);
          },
          selected: provider.scale == scale,
          selectedTileColor: Colors.purple.withOpacity(0.2),
        )).toList(),
      ),
    );
  }

  String _getRateLabel(ArpRate rate) {
    switch (rate) {
      case ArpRate.rate1_4: return '1/4';
      case ArpRate.rate1_8: return '1/8';
      case ArpRate.rate1_16: return '1/16';
      case ArpRate.rate1_32: return '1/32';
    }
  }

  void _showModePicker(BuildContext context, ArpeggiatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ArpMode.values.map((mode) => ListTile(
          title: Text(mode.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
          onTap: () {
            provider.setMode(mode);
            Navigator.pop(context);
          },
          selected: provider.mode == mode,
          selectedTileColor: Colors.purple.withOpacity(0.2),
        )).toList(),
      ),
    );
  }

  void _showRatePicker(BuildContext context, ArpeggiatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ArpRate.values.map((rate) => ListTile(
          title: Text(_getRateLabel(rate), style: const TextStyle(color: Colors.white)),
          onTap: () {
            provider.setRate(rate);
            Navigator.pop(context);
          },
          selected: provider.rate == rate,
          selectedTileColor: Colors.purple.withOpacity(0.2),
        )).toList(),
      ),
    );
  }
}

class _ArpOption extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ArpOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
