import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/config/theme.dart';

/// An adaptive loading indicator that displays platform-appropriate spinners.
/// - iOS/macOS: CupertinoActivityIndicator
/// - Android/Web/other: Material CircularProgressIndicator
class AdaptiveLoadingIndicator extends StatelessWidget {
  final String? message;

  const AdaptiveLoadingIndicator({super.key, this.message});

  bool get _useCupertino =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    if (_useCupertino) {
      return const CupertinoActivityIndicator(radius: 14.0);
    }
    return const CircularProgressIndicator(color: AppTheme.primaryColor);
  }
}
