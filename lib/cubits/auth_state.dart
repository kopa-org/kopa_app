import 'package:kopa/model/user_details.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

const Object _unset = Object();

class AuthState {
  final AuthStatus status;
  final UserDetails? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _unset,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _unset ? this.user : user as UserDetails?,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
