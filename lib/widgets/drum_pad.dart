import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrumPad extends StatefulWidget {
  final int index;
  final Color color;
  final String sampleName;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onLoopToggle;
  final bool isLoop;

  const DrumPad({
    super.key,
    required this.index,
    required this.color,
    required this.sampleName,
    required this.isPlaying,
    required this.onTap,
    required this.onLongPress,
    required this.onLoopToggle,
    required this.isLoop,
  });

  @override
  State<DrumPad> createState() => _DrumPadState();
}

class _DrumPadState extends State<DrumPad> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    widget.onTap();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      onLongPressStart: (_) => HapticFeedback.mediumImpact(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: _isPressed
                    ? LinearGradient(
                        colors: [widget.color.withOpacity(0.5), widget.color.withOpacity(0.3)],
                      )
                    : LinearGradient(
                        colors: [widget.color, widget.color.withOpacity(0.7)],
                      ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: _isPressed ? 5 : 15,
                    spreadRadius: _isPressed ? 0 : 2,
                    offset: Offset(0, _isPressed ? 2 : 5),
                  ),
                ],
                border: Border.all(
                  color: widget.isLoop ? Colors.white : Colors.white24,
                  width: widget.isLoop ? 3 : 1,
                ),
              ),
              child: Stack(
                children: [
                  // Loop indicator
                  if (widget.isLoop)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            widget.sampleName.length > 12
                                ? '${widget.sampleName.substring(0, 10)}...'
                                : widget.sampleName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ripple effect overlay
                  if (_isPressed)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
