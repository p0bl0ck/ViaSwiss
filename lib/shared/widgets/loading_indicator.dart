import 'package:flutter/material.dart';

import 'adaptive/adaptive_loading_indicator.dart';

/// Loading indicator that adapts to the platform.
/// - iOS/macOS: CupertinoActivityIndicator
/// - Android/Web/other: Material CircularProgressIndicator
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLoadingIndicator(message: message);
  }
}
