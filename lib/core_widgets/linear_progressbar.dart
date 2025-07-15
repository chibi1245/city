import 'package:flutter/material.dart';

class LinearProgressbar extends StatelessWidget {
  final double height;
  final double? total;
  final double? separator;
  final Color valueColor;
  final Color background;

  const LinearProgressbar({required this.height, required this.valueColor, required this.background, this.separator, this.total});

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.circular(4);
    return TweenAnimationBuilder<double>(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: (total ?? 0) / (separator ?? 1)),
      builder: (context, value, _) => ClipRRect(borderRadius: radius, child: _indicator(value)),
    );
  }

  Widget _indicator(double value) {
    var colorValue = AlwaysStoppedAnimation(valueColor);
    return LinearProgressIndicator(value: value, minHeight: height, backgroundColor: background, valueColor: colorValue);
  }
}
