import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sample_provider.dart';

class BankSelector extends StatelessWidget {
  const BankSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SampleProvider>(
      builder: (context, sampleProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text(
                'BANK:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: List.generate(
                    sampleProvider.numBanks,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _BankButton(
                          label: String.fromCharCode(65 + index),
                          isSelected: sampleProvider.currentBank == index,
                          onTap: () => sampleProvider.setBank(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _NavButton(
                icon: Icons.chevron_left,
                onTap: sampleProvider.previousBank,
              ),
              const SizedBox(width: 8),
              _NavButton(
                icon: Icons.chevron_right,
                onTap: sampleProvider.nextBank,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
