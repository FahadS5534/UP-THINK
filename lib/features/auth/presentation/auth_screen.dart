import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/upthink_logo.dart';
import '../../../shared/models/app_user.dart';
import '../providers/auth_provider.dart';

/// Upthink Authentication Screen
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController(text: 'elena.vass@oxford.ac.uk');
  final TextEditingController _passwordController = TextEditingController(text: 'scholar2026!');
  final TextEditingController _nameController = TextEditingController(text: 'Elena Vass');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await ref.read(authStateProvider.notifier).signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _nameController.text.trim(),
            );
      } else {
        await ref.read(authStateProvider.notifier).signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }

      if (mounted) {
        final user = ref.read(authStateProvider).value;
        if (user != null && user.isFacilitator) {
          context.go('/cohort');
        } else {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Upthink Brand Header
                  const UpthinkLogo(size: 40, showWordmark: true),
                  const SizedBox(height: 8),
                  Text(
                    'Think beyond memorization.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMediumContrast,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Auth Card
                  GlassPanel(
                    backgroundColor: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUp ? 'Create Scholar Account' : 'Academic Sign In',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHighContrast,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSignUp
                              ? 'Enter your institutional credentials to enroll.'
                              : 'Access your learning diagnostics and adaptive plans.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const SizedBox(height: 18),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.highRiskBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.highRiskBorder),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodySm.copyWith(color: AppColors.highRisk),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (_isSignUp) ...[
                          _buildTextField('Full Name', _nameController, false),
                          const SizedBox(height: 12),
                        ],

                        _buildTextField('Institutional Email', _emailController, false),
                        const SizedBox(height: 12),

                        _buildTextField('Password', _passwordController, true),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Enroll Account' : 'Authenticate',
                                    style: AppTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Switch sign in / sign up toggle
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _errorMessage = null;
                              });
                            },
                            child: Text(
                              _isSignUp
                                  ? 'Already registered? Sign In'
                                  : 'New scholar? Register with Upthink',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Demo Switchers
                  Text(
                    'OR EXPLORE DEMO PROFILES',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textLowContrast,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).switchRole(UserRole.student);
                            if (context.mounted) context.go('/dashboard');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.glassBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Student (Elena Vass)',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textHighContrast,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).switchRole(UserRole.facilitator);
                            if (context.mounted) context.go('/cohort');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.glassBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Faculty (Dr. Hawthorne)',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSm.copyWith(
            fontSize: 10,
            color: AppColors.textMediumContrast,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textHighContrast),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
