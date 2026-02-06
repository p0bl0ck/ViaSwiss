import 'package:flutter/material.dart';

import 'adaptive/adaptive_card.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
