import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'upthink_logo.dart';

/// Authoritative Editorial App Header
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? sectionSubtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool isFacilitator;

  const AppHeader({
    super.key,
    required this.title,
    this.sectionSubtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.onNotificationTap,
    this.onProfileTap,
    this.isFacilitator = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.90),
        border: const Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBack) ...[
                IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: AppColors.textMediumContrast,
                  tooltip: 'Go back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 8),
              ],
              // Brand & Section
              Expanded(
                child: Row(
                  children: [
                    if (!showBack) const UpthinkLogo(size: 26, showWordmark: false),
                    if (!showBack) const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isFacilitator ? 'FACULTY MATRIX' : 'UPTHINK',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  height: 1.0,
                                ),
                              ),
                              if (isFacilitator) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'FACILITATOR',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing Actions
              if (trailing != null)
                trailing!
              else ...[
                // Notifications icon with active pulse dot
                IconButton(
                  onPressed: onNotificationTap,
                  tooltip: 'Notifications',
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        size: 22,
                        color: AppColors.textMediumContrast,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x99C8F169),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Avatar button
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isFacilitator
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isFacilitator ? 'FC' : 'EV',
                        style: AppTypography.labelSm.copyWith(
                          color: isFacilitator
                              ? AppColors.onSecondaryContainer
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
