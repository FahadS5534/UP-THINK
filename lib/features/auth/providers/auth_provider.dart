import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_user.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            fullName: fullName,
          );
    });
  }

  Future<void> switchRole(UserRole role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).switchRole(role);
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = AsyncValue.data(AuthRepository.getDemoStudent());
  }

  void updateUser(AppUser user) {
    state = AsyncValue.data(user);
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AppUser>(AuthNotifier.new);
