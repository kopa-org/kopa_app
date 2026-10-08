import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:kopa/services/push_notifications_service.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:kopa/repository/match_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final Future<void> Function() _unregisterPushToken;

  PasswordResetRepository get _passwordResetRepository {
    final repository = _authRepository;
    if (repository is PasswordResetRepository) {
      return repository as PasswordResetRepository;
    }
    throw UnsupportedError(
        'Password reset is not supported by this repository');
  }

  AuthCubit({
    required AuthRepository authRepository,
    Future<void> Function()? unregisterPushToken,
  })  : _authRepository = authRepository,
        _unregisterPushToken = unregisterPushToken ??
            PushNotificationsService.instance.unregisterCurrentToken,
        super(const AuthState());

  Future<void> init() async {
    final hasAuthenticatedBefore = await _hasAuthenticatedBefore();
    emit(state.copyWith(
      status: AuthStatus.loading,
      hasAuthenticatedBefore: hasAuthenticatedBefore,
    ));
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        await SecureStorageService.setHasAuthenticatedBefore();
        await AppAnalytics.setCurrentUser(user);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          hasAuthenticatedBefore: true,
        ));
      } else {
        await AppAnalytics.setCurrentUser(null);
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> _hasAuthenticatedBefore() async {
    try {
      return await SecureStorageService.hasAuthenticatedBefore();
    } catch (error, stack) {
      debugPrint('Auth bootstrap storage read failed: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final success = await _authRepository.login(email, password);
    if (success) {
      MatchRepository.invalidateMatchSummaries();
      final user = await _authRepository.getCurrentUser();
      await SecureStorageService.setHasAuthenticatedBefore();
      await AppAnalytics.logLogin(success: true);
      await AppAnalytics.setCurrentUser(user);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        hasAuthenticatedBefore: true,
      ));
    } else {
      await AppAnalytics.logLogin(success: false);
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Login failed. Please check your credentials.',
      ));
    }
  }

  Future<void> logout() async {
    // Try while credentials are still available, but a failed remote cleanup
    // must not prevent the user from ending their local session.
    try {
      await _unregisterPushToken();
    } catch (error) {
      debugPrint('Push token cleanup during logout failed: $error');
    }
    await _authRepository.logout();
    MatchRepository.invalidateMatchSummaries();
    await AppAnalytics.setCurrentUser(null);
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      hasAuthenticatedBefore: true,
    ));
  }

  Future<void> requestPasswordResetCode(String email) {
    return _passwordResetRepository.requestPasswordResetCode(email);
  }

  Future<bool> verifyPasswordResetCode(String email, String code) {
    return _passwordResetRepository.verifyPasswordResetCode(email, code);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final user = await _passwordResetRepository.resetPassword(
      email: email,
      code: code,
      password: password,
    );
    MatchRepository.invalidateMatchSummaries();
    await SecureStorageService.setHasAuthenticatedBefore();
    await AppAnalytics.setCurrentUser(user);
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      hasAuthenticatedBefore: true,
    ));
  }

  void updateUser(UserDetails user) {
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> register(String name, String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        roleId: 2, // Default roleId from previous register page
      );
      if (success) {
        await AppAnalytics.logRegister(success: true);
        // Automatically login after successful registration
        await login(email, password);
      } else {
        await AppAnalytics.logRegister(success: false);
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Registration failed. Please try again.',
        ));
      }
    } catch (e) {
      await AppAnalytics.logRegister(success: false);
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
