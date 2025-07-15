import 'package:flutter/material.dart';

class PopScopeNavigator extends StatelessWidget {
  final Widget child;
  final bool canPop;
  final Function()? onPop;

  const PopScopeNavigator({required this.child, required this.canPop, this.onPop});

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: canPop, child: child, onPopInvoked: onPop == null ? null : onPopInvoked);
  }

  void onPopInvoked(bool didPop) {
    if (didPop) return;
    if (onPop != null) onPop!;
  }
}
