import 'package:flutter/material.dart';




typedef ResponsiveBuilder = Widget Function(BuildContext context, Orientation orientation);

class ScreenCraft extends StatelessWidget {
  final ResponsiveBuilder builder;
  const ScreenCraft({required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeConfig.initLayoutBuilder(constraints, orientation);
        return builder(context, orientation);
      });
    });
  }
}

class SizeConfig {
  static void initLayoutBuilder(BoxConstraints constraints, Orientation orientation) {}
}
