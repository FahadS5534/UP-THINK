import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/services/supabase_service.dart';

/// Authentication & Role-Aware Repository
class AuthRepository {
  static const String _prefRoleKey = 'upthink_user_role';

  /// Sign In with Email & Password via Supabase Auth
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        final res = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (res.user != null) {
          final profileData = await client
              .from('profiles')
              .select()
              .eq('id', res.user!.id)
              .maybeSingle();

          if (profileData != null) {
            return AppUser.fromJson(profileData);
          }
        }
      } catch (_) {
        // Fallback to local demo profile
      }
    }

    // Default demo student or facilitator
    if (email.toLowerCase().contains('faculty') || email.toLowerCase().contains('facilitator')) {
      return getDemoFacilitator();
    }
    return getDemoStudent();
  }

  /// Sign Up with Email & Password
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        final res = await client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
        if (res.user != null) {
          // Public registrations default to STUDENT role
          final newProfile = {
            'id': res.user!.id,
            'email': email,
            'full_name': fullName,
            'role': 'STUDENT',
          };
          await client.from('profiles').insert(newProfile);
          return AppUser.fromJson(newProfile);
        }
      } catch (_) {
        // Fallback
      }
    }

    return getDemoStudent().copyWith(fullName: fullName,);
  }

  /// Sign Out
  Future<void> signOut() async {
    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
  }

  /// Get current session or persisted demo role
  Future<AppUser> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString(_prefRoleKey);

    if (savedRole == 'FACILITATOR') {
      return getDemoFacilitator();
    }
    return getDemoStudent();
  }

  /// Switch active role (for demonstration and testing)
  Future<AppUser> switchRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefRoleKey, role == UserRole.facilitator ? 'FACILITATOR' : 'STUDENT');
    if (role == UserRole.facilitator) {
      return getDemoFacilitator();
    }
    return getDemoStudent();
  }

  static AppUser getDemoStudent() {
    return const AppUser(
      id: 'student-elena-vass-id',
      email: 'elena.vass@oxford.ac.uk',
      fullName: 'Elena Vass',
      role: UserRole.student,
      university: 'University of Oxford',
      department: 'Mathematical Institute & Computer Science',
      academicLevel: 'Undergraduate Scholar • MMath CompSci',
      remediationAggression: 'intensive',
      latexRendering: true,
      ragCitations: true,
      dynamicCalibration: true,
      interventionAlerts: true,
      studyVolumeHours: 64.5,
      masteredNodesCount: 148,
      diagnosticsPassedCount: 18,
      cohortPercentile: 88,
    );
  }

  static AppUser getDemoFacilitator() {
    return const AppUser(
      id: 'faculty-charles-hawthorne-id',
      email: 'c.hawthorne@oxford.ac.uk',
      fullName: 'Dr. Charles Hawthorne',
      role: UserRole.facilitator,
      university: 'University of Oxford',
      department: 'Faculty of Mathematics',
      academicLevel: 'Associate Professor • Machine Learning Foundry',
      remediationAggression: 'balanced',
      latexRendering: true,
      ragCitations: true,
      dynamicCalibration: true,
      interventionAlerts: true,
      studyVolumeHours: 120.0,
      masteredNodesCount: 320,
      diagnosticsPassedCount: 45,
      cohortPercentile: 99,
    );
  }
}
