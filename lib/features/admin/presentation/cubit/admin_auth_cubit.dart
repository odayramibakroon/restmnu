import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/error_messages.dart';
import '../../data/admin_repository.dart';
import 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AdminRepository repository;
  late final StreamSubscription _authSubscription;

  AdminAuthCubit({required this.repository})
    : super(const AdminAuthState.loading()) {
    _authSubscription = repository.authStateChanges.listen(_syncAuthUser);
  }

  Future<void> signIn({required String email, required String password}) async {
    if (isClosed) return;
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      emit(
        AdminAuthState(
          status: AdminAuthStatus.error,
          user: state.user,
          errorMessage: ErrorMessages.message(
            AppErrorKey.emailPasswordRequired,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(status: AdminAuthStatus.submitting));

    try {
      final credential = await repository.signIn(
        email: trimmedEmail,
        password: password,
      );
      final user = credential.user ?? repository.currentUser;
      if (!isClosed && user != null) {
        emit(AdminAuthState(status: AdminAuthStatus.authenticated, user: user));
      }
    } catch (e) {
      if (isClosed) return;
      emit(
        AdminAuthState(
          status: AdminAuthStatus.error,
          user: state.user,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
  }

  Future<void> _syncAuthUser(User? user) async {
    if (isClosed) return;
    if (user == null) {
      emit(
        const AdminAuthState(
          status: AdminAuthStatus.unauthenticated,
          user: null,
        ),
      );
      return;
    }

    try {
      await repository.ensureAdminAccess(user);
      if (isClosed) return;
      emit(AdminAuthState(status: AdminAuthStatus.authenticated, user: user));
    } catch (e) {
      if (isClosed) return;
      emit(
        AdminAuthState(
          status: AdminAuthStatus.error,
          user: null,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
