import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Five-Item Bottom Navigation Bar matching the Stitch specification
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isFacilitator;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isFacilitator = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFacilitator) {
      // Facilitator navigation (Cohort Dashboard, Assessments Authoring, Profile)
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.query_stats_outlined,
                  activeIcon: Icons.query_stats,
                  label: 'Cohort',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Authoring',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.account_circle_outlined,
                  activeIcon: Icons.account_circle,
                  label: 'Faculty',
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Student 5-item navigation: Home, Learn, Tutor, Plan, Profile
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.auto_stories_outlined,
                activeIcon: Icons.auto_stories,
                label: 'Learn',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.psychology_outlined,
                activeIcon: Icons.psychology,
                label: 'Tutor',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune,
                label: 'Plan',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.account_circle_outlined,
                activeIcon: Icons.account_circle,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textMediumContrast,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMediumContrast,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 12,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}
