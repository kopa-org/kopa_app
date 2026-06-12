import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:kopa/services/push_notifications_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  Future<void> init() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        await AppAnalytics.setCurrentUser(user);
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        await AppAnalytics.setCurrentUser(null);
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final success = await _authRepository.login(email, password);
    if (success) {
      final user = await _authRepository.getCurrentUser();
      await AppAnalytics.logLogin(success: true);
      await AppAnalytics.setCurrentUser(user);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      await AppAnalytics.logLogin(success: false);
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Login failed. Please check your credentials.',
      ));
    }
  }

  Future<void> logout() async {
    await PushNotificationsService.instance.unregisterCurrentToken();
    await _authRepository.logout();
    await AppAnalytics.setCurrentUser(null);
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
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
