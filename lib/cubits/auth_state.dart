import 'package:equatable/equatable.dart';
import 'package:kopa/model/user_details.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

const Object _unset = Object();

class AuthState extends Equatable {
  final AuthStatus status;
  final UserDetails? user;
  final String? errorMessage;
  final bool hasAuthenticatedBefore;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.hasAuthenticatedBefore = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _unset,
    String? errorMessage,
    bool? hasAuthenticatedBefore,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _unset ? this.user : user as UserDetails?,
      errorMessage: errorMessage ?? this.errorMessage,
      hasAuthenticatedBefore:
          hasAuthenticatedBefore ?? this.hasAuthenticatedBefore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        hasAuthenticatedBefore,
      ];
}
