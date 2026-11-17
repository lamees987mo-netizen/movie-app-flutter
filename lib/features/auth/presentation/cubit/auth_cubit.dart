import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_state.dart';

export 'auth_state.dart';

/// The signed-in user, for the whole app.
///
/// A get_it singleton provided above `MaterialApp` (like `SettingsCubit`),
/// so any screen can read it. It only follows
/// [AuthRepository.userChanges]: signing in and out is done by the sign-in
/// and account screens' own cubits, and this cubit sees the result.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
    : super(_stateFor(repository.currentUser)) {
    _subscription = repository.userChanges().listen(
      (user) => emit(_stateFor(user)),
      // Keep the last known user; Firebase keeps the stream open.
      onError: (Object error, StackTrace stackTrace) =>
          log('User stream error', error: error, stackTrace: stackTrace),
    );
  }

  late final StreamSubscription<AppUser?> _subscription;

  static AuthState _stateFor(AppUser? user) =>
      user == null ? const AuthSignedOut() : AuthSignedIn(user);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
