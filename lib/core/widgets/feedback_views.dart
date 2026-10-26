import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Loading State
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Synthesizing knowledge vectors...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textMediumContrast,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Error State
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.title = 'Inference Interrupted',
    this.message = 'An unexpected variance occurred during data retrieval.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 36,
              color: AppColors.highRisk,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.highRisk,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textMediumContrast,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                label: Text(
                  'RETRY',
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable Empty State
class EmptyStateView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: AppColors.textLowContrast,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.headlineSm.copyWith(
                fontSize: 16,
                color: AppColors.textHighContrast,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textMediumContrast,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
