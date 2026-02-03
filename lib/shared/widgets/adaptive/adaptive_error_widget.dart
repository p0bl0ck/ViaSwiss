import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/config/theme.dart';

/// An adaptive error widget that displays platform-appropriate styling.
/// - iOS/macOS: Cupertino icons and buttons
/// - Android/Web/other: Material icons and buttons
class AdaptiveErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AdaptiveErrorWidget({super.key, required this.message, this.onRetry});

  bool get _useCupertino => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              _buildRetryButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (_useCupertino) {
      return const Icon(
        CupertinoIcons.exclamationmark_circle,
        color: CupertinoColors.systemRed,
        size: 64,
      );
    }
    return const Icon(
      Icons.error_outline,
      color: AppTheme.errorColor,
      size: 64,
    );
  }

  Widget _buildRetryButton() {
    if (_useCupertino) {
      return CupertinoButton(onPressed: onRetry, child: const Text('Retry'));
    }
    return ElevatedButton(onPressed: onRetry, child: const Text('Retry'));
  }
}
