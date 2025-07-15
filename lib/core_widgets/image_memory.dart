import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:grs/themes/light_theme.dart';

class ImageMemory extends StatelessWidget {
  final Function()? onTap;
  final Uint8List? imagePath;
  final double radius;
  final double size;
  final Widget? errorWidget;
  final BoxFit? imageFit;
  final Color? borderColor;

  const ImageMemory({
    required this.imagePath,
    this.radius = 50,
    this.size = 32,
    this.imageFit = BoxFit.cover,
    this.onTap,
    this.errorWidget,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    var border = borderColor == null ? null : Border.all(color: grey40);
    var decoration = BoxDecoration(borderRadius: BorderRadius.circular(radius), border: border);
    return InkWell(onTap: onTap, child: Container(width: size, height: size, decoration: decoration, child: _profileImage(context)));
  }

  Widget _profileImage(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: imagePath == null ? errorWidget : _memoryImage(context));
  }

  Widget _memoryImage(BuildContext context) {
    return Image.memory(
      imagePath!,
      fit: imageFit ?? BoxFit.contain,
      colorBlendMode: BlendMode.darken,
      filterQuality: FilterQuality.high,
      errorBuilder: errorWidget == null ? null : (context, exception, stackTrace) => errorWidget!,
    );
  }
}
