import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

/// Tracks whether the app is currently locked behind biometric / PIN authentication.
final authLockProvider = StateProvider<bool>((ref) => false);

/// State notifier managing persisted onboarding completion status.
class OnboardingNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  static const String _key = 'farmivo_onboarding_completed';

  OnboardingNotifier({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      final val = await _storage.read(key: _key);
      if (val != null) {
        state = val == 'true';
      }
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    state = true;
    try {
      await _storage.write(key: _key, value: 'true');
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = false;
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      return OnboardingNotifier();
    });

/// Reactive bridge notifying GoRouter whenever auth lock or onboarding status changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen<bool>(authLockProvider, (_, __) => notifyListeners());
    ref.listen<bool>(onboardingCompletedProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Decides whether a navigation request must be redirected for security or onboarding.
String? appRouteRedirect(GoRouterState state, Ref ref) {
  final isLocked = ref.read(authLockProvider);
  final isOnboardingCompleted = ref.read(onboardingCompletedProvider);

  final isGoingToLock = state.matchedLocation == AppRoutes.lock;
  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

  // 1. PIN / Biometrics Guard
  if (isLocked && !isGoingToLock) {
    return AppRoutes.lock;
  }

  // 2. Onboarding Guard
  if (!isOnboardingCompleted && !isGoingToOnboarding && !isLocked) {
    return AppRoutes.onboarding;
  }

  // If unlocked and trying to visit lock screen, send home
  if (!isLocked && isGoingToLock) {
    return AppRoutes.dashboard;
  }

  return null;
}
