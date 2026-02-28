import 'package:flutter/material.dart';

class PanicDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onPanic;

  const PanicDetector({
    super.key,
    required this.child,
    required this.onPanic,
  });

  @override
  State<PanicDetector> createState() => _PanicDetectorState();
}

class _PanicDetectorState extends State<PanicDetector> {
  int tapCount = 0;
  DateTime? lastTap;

  void registerTap() {
    final now = DateTime.now();

    // reset if delay too long
    if (lastTap == null ||
        now.difference(lastTap!) > const Duration(seconds: 2)) {
      tapCount = 0;
    }

    tapCount++;
    lastTap = now;

    if (tapCount >= 3) {
      tapCount = 0;
      widget.onPanic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: registerTap,
      child: widget.child,
    );
  }
}