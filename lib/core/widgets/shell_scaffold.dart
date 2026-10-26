import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'app_bottom_navigation.dart';
import 'app_header.dart';

/// Mobile Tab Shell Scaffold for Upthink
class ShellScaffold extends ConsumerWidget {
  final Widget child;
  final String location;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _calculateIndex(bool isFacilitator) {
    if (isFacilitator) {
      if (location.startsWith('/cohort')) return 0;
      if (location.startsWith('/authoring')) return 1;
      if (location.startsWith('/profile')) return 2;
      return 0;
    }

    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/tutor')) return 2;
    if (location.startsWith('/plan')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  String _getHeaderTitle(bool isFacilitator) {
    if (isFacilitator) {
      if (location.startsWith('/cohort')) return 'Facilitator Workspace';
      if (location.startsWith('/authoring')) return 'Facilitator Assessments';
      if (location.startsWith('/profile')) return 'Faculty Profile';
      return 'Facilitator Workspace';
    }

    if (location.startsWith('/dashboard')) return 'Home';
    if (location.startsWith('/learn')) return 'Learn';
    if (location.startsWith('/tutor')) return 'Tutor';
    if (location.startsWith('/plan')) return 'Plan';
    if (location.startsWith('/profile')) return 'Profile & Settings';
    return 'Home';
  }

  void _onNavTap(BuildContext context, int index, bool isFacilitator) {
    if (isFacilitator) {
      switch (index) {
        case 0:
          context.go('/cohort');
          break;
        case 1:
          context.go('/authoring');
          break;
        case 2:
          context.go('/profile');
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/learn');
        break;
      case 2:
        context.go('/tutor');
        break;
      case 3:
        context.go('/plan');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.value;
    final isFacilitator = user?.isFacilitator ?? false;
    final currentIndex = _calculateIndex(isFacilitator);
    final headerTitle = _getHeaderTitle(isFacilitator);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppHeader(
        title: headerTitle,
        isFacilitator: isFacilitator,
        onProfileTap: () => context.go('/profile'),
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cognitive drift & performance alerts verified.'),
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          );
        },
      ),
      body: child,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        isFacilitator: isFacilitator,
        onTap: (idx) => _onNavTap(context, idx, isFacilitator),
      ),
    );
  }
}
