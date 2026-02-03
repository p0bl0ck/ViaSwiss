import 'package:flutter/material.dart';

import 'adaptive/adaptive_error_widget.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AdaptiveErrorWidget(message: message, onRetry: onRetry);
  }
}
