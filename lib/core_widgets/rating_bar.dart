import 'dart:math' as math;

import 'package:flutter/material.dart';

class RatingWidget {
  final Widget full;
  final Widget half;
  final Widget empty;

  RatingWidget({required this.full, required this.half, required this.empty});
}

class RatingBar extends StatefulWidget {
  final ValueChanged<double> onRatingUpdate;
  final double? maxRating;
  final Color? unratedColor;
  final Axis direction;
  final bool ignoreGestures;
  final double initialRating;
  final int itemCount;
  final EdgeInsetsGeometry itemPadding;
  final double itemSize;
  final double minRating;
  final WrapAlignment wrapAlignment;
  final RatingWidget ratingWidget;

  const RatingBar({
    required this.onRatingUpdate,
    required this.ratingWidget,
    this.maxRating,
    this.unratedColor,
    this.direction = Axis.horizontal,
    this.ignoreGestures = false,
    this.initialRating = 0.0,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40.0,
    this.minRating = 0,
    this.wrapAlignment = WrapAlignment.start,
  });

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  double _rating = 0;
  double iconRating = 0;

  late final ValueNotifier<bool> _glow;

  @override
  void initState() {
    super.initState();
    _glow = ValueNotifier(false);
    _rating = widget.initialRating;
  }

  @override
  void didUpdateWidget(RatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    iconRating = 0.0;
    return Wrap(
      textDirection: textDirection,
      direction: widget.direction,
      children: List.generate(widget.itemCount, (index) => _buildRating(context, index)),
    );
  }

  Widget _buildRating(BuildContext context, int index) {
    final ratingWidget = widget.ratingWidget;
    Widget _ratingWidget;
    final glowColor = Theme.of(context).colorScheme.secondary;
    var shadow1 = BoxShadow(color: glowColor.withAlpha(30), blurRadius: 10);
    var shadow2 = BoxShadow(color: glowColor.withAlpha(20), blurRadius: 10);
    var decoration = BoxDecoration(shape: BoxShape.circle, boxShadow: [shadow1, shadow2]);
    if (index >= _rating) {
      var unratedColor = widget.unratedColor ?? Theme.of(context).disabledColor;
      _ratingWidget = _NoRatingWidget(size: widget.itemSize, child: ratingWidget.empty, unratedColor: unratedColor);
    } else {
      _ratingWidget = SizedBox(width: widget.itemSize, height: widget.itemSize, child: FittedBox(child: ratingWidget.full));
      iconRating += 1.0;
    }

    return IgnorePointer(
      ignoring: widget.ignoreGestures,
      child: GestureDetector(
        onTapDown: (details) {
          double value = (index == 0 && (_rating == 1 || _rating == 0.5)) ? 0 : index + 1.0;
          value = math.max(value, widget.minRating);
          widget.onRatingUpdate(value);
          _rating = value;
          setState(() {});
        },
        onHorizontalDragStart: _isHorizontal ? _onDragStart : null,
        onHorizontalDragEnd: _isHorizontal ? _onDragEnd : null,
        onVerticalDragStart: _isHorizontal ? null : _onDragStart,
        onVerticalDragEnd: _isHorizontal ? null : _onDragEnd,
        child: Padding(
          padding: widget.itemPadding,
          child: ValueListenableBuilder<bool>(
            valueListenable: _glow,
            child: _ratingWidget,
            builder: (context, glow, child) {
              if (glow) return DecoratedBox(decoration: decoration, child: child);
              return child!;
            },
          ),
        ),
      ),
    );
  }

  bool get _isHorizontal => widget.direction == Axis.horizontal;

  void _onDragStart(DragStartDetails details) => _glow.value = true;

  void _onDragEnd(DragEndDetails details) {
    _glow.value = false;
    widget.onRatingUpdate(iconRating);
    iconRating = 0.0;
  }
}

class _NoRatingWidget extends StatelessWidget {
  final double size;
  final Widget child;
  final Color unratedColor;

  const _NoRatingWidget({required this.size, required this.child, required this.unratedColor});

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size, child: FittedBox(child: child));
}
