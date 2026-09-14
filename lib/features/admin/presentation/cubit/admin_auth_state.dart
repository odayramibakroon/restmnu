import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AdminAuthStatus {
  loading,
  authenticated,
  unauthenticated,
  submitting,
  error,
}

class AdminAuthState extends Equatable {
  final AdminAuthStatus status;
  final User? user;
  final String? errorMessage;

  const AdminAuthState({required this.status, this.user, this.errorMessage});

  const AdminAuthState.loading()
    : status = AdminAuthStatus.loading,
      user = null,
      errorMessage = null;

  bool get isAuthenticated => user != null;

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user?.uid, errorMessage];
}
