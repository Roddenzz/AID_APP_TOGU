import 'package:flutter/material.dart';

class StaggeredFadeIn extends StatelessWidget {
  final Animation<double> controller;
  final Widget child;
  final int index;
  final double delay;

  const StaggeredFadeIn({
    Key? key,
    required this.controller,
    required this.child,
    this.index = 0,
    this.delay = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intervalStart = (index * delay).clamp(0.0, 1.0);
    final intervalEnd = (intervalStart + 0.5).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
