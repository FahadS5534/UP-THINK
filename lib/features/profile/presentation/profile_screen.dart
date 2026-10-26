import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Screen 9: Profile and Academic Settings
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _remediationSegment = 'intensive';
  bool _latexRendering = true;
  bool _ragCitations = true;
  bool _dynamicCalibration = true;
  bool _interventionAlerts = true;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.value ?? AuthRepository.getDemoStudent();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileHeaderCard(user),
            const SizedBox(height: 16),

            // Academic Vector Metrics (2x2 Grid)
            _buildAcademicMetricsGrid(user),
            const SizedBox(height: 18),

            // Epistemic AI & Study Preferences Section
            _buildStudyPreferencesSection(user),
            const SizedBox(height: 18),

            // Notification Enclave Section
            _buildNotificationEnclaveSection(),
            const SizedBox(height: 18),

            // Syllabus Document Management
            _buildSyllabusUploadSection(),
            const SizedBox(height: 20),

            // Account & Role Switcher Actions
            _buildAccountActions(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(AppUser user) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with active green dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: user.isFacilitator
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.isFacilitator ? 'FC' : 'EV',
                        style: AppTypography.headlineSm.copyWith(
                          color: user.isFacilitator
                              ? AppColors.onSecondaryContainer
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x99C8F169),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.fullName,
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHighContrast,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.academicLevel,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.textMediumContrast,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Institutional Enclave Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.university,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textHighContrast,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SAML 2.0',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicMetricsGrid(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACADEMIC VECTOR METRICS',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
            ),
            Text(
              'Cohort Ranked',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Study Volume',
                value: '${user.studyVolumeHours}',
                unit: 'h',
                subtitle: '+4.2h this week',
                trailingIcon: const Icon(Icons.timelapse, size: 16, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Mastery Nodes',
                value: '${user.masteredNodesCount}',
                subtitle: '92% retention rate',
                trailingIcon: const Icon(Icons.hub_outlined, size: 16, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Diagnostics',
                value: '${user.diagnosticsPassedCount}',
                unit: 'Passed',
                subtitle: 'Discrete Math & ML',
                trailingIcon: const Icon(Icons.assignment_turned_in_outlined, size: 16, color: AppColors.textMediumContrast),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Cohort Rank',
                value: '${user.cohortPercentile}',
                unit: 'th',
                subtitle: 'Top 12% in Oxford cohort',
                valueColor: AppColors.primary,
                trailingIcon: const Icon(Icons.military_tech_outlined, size: 16, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudyPreferencesSection(AppUser user) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Epistemic AI & Study Preferences',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Adaptive Remediation Segmented Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adaptive Remediation',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _remediationSegment.toUpperCase(),
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Governs the velocity of Socratic interventions during low-confidence retrieval episodes.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textMediumContrast,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),

          // 3-Segment Button
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSegmentButton('conservative', 'Conservative'),
                _buildSegmentButton('balanced', 'Balanced'),
                _buildSegmentButton('intensive', 'Intensive'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 10),

          // Toggle 1: LaTeX Rendering
          _buildToggleRow(
            icon: Icons.functions,
            title: 'LaTeX & Formula Rendering',
            subtitle: 'Render proof trees and inline tensor equations natively via KaTeX.',
            value: _latexRendering,
            onChanged: (val) {
              setState(() => _latexRendering = val);
              ref.read(profileRepositoryProvider).updateSettings(
                    user: user,
                    latexRendering: val,
                  );
            },
          ),
          const SizedBox(height: 12),

          // Toggle 2: Vector RAG Citations
          _buildToggleRow(
            icon: Icons.menu_book,
            title: 'Vector RAG Citations',
            subtitle: 'Always link lecture slides & Oxford syllabus chapters in AI dialogues.',
            value: _ragCitations,
            onChanged: (val) {
              setState(() => _ragCitations = val);
              ref.read(profileRepositoryProvider).updateSettings(
                    user: user,
                    ragCitations: val,
                  );
            },
          ),
          const SizedBox(height: 12),

          // Toggle 3: Dynamic Calibration
          _buildToggleRow(
            icon: Icons.tune,
            title: 'Dynamic Calibration',
            subtitle: 'Modulate problem difficulty dynamically to target 70% epistemic tension.',
            value: _dynamicCalibration,
            onChanged: (val) {
              setState(() => _dynamicCalibration = val);
              ref.read(profileRepositoryProvider).updateSettings(
                    user: user,
                    dynamicCalibration: val,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String id, String label) {
    final isSelected = _remediationSegment == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _remediationSegment = id),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.onPrimary : AppColors.textMediumContrast,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.textMediumContrast),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 11,
                  color: AppColors.textMediumContrast,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.textMediumContrast,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildNotificationEnclaveSection() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Notification Enclave',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            icon: Icons.warning_amber_rounded,
            title: 'Intervention & Risk Alerts',
            subtitle: 'Real-time alerts when epistemic drift or retention decay crosses 30%.',
            value: _interventionAlerts,
            onChanged: (val) => setState(() => _interventionAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusUploadSection() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Course Material & Syllabus Ingestion',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Upload course syllabus or lecture slides to enable semantic RAG groundings in AI Tutor.',
            style: AppTypography.bodySm.copyWith(
              fontSize: 11,
              color: AppColors.textMediumContrast,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(profileRepositoryProvider).uploadSyllabusDocument(
                    title: 'MATH 302 Lecture Notes',
                    courseCode: 'MATH-302',
                    fileName: 'math_302_syllabus.pdf',
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syllabus uploaded and indexed for RAG retrieval.'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            icon: const Icon(Icons.upload_file, size: 16, color: AppColors.primary),
            label: Text(
              'Upload Syllabus PDF',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, AppUser user) {
    return Column(
      children: [
        // Role Switcher Button (Demo mode for pairing evaluation)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              final nextRole = user.isFacilitator ? UserRole.student : UserRole.facilitator;
              ref.read(authStateProvider.notifier).switchRole(nextRole);
              if (nextRole == UserRole.facilitator) {
                context.go('/cohort');
              } else {
                context.go('/dashboard');
              }
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(
              user.isFacilitator ? 'Switch to Student View (Elena Vass)' : 'Switch to Facilitator View (Faculty Matrix)',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) context.go('/auth');
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.highRisk,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
