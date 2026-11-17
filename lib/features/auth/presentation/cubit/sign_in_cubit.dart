import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_state.dart';

export 'sign_in_state.dart';

/// Runs the sign-in screen's actions: Google, email sign-in and sign-up,
/// and "Forgot password".
///
/// It does not keep the new user: `AuthCubit` hears about it from the
/// repository's user stream.
class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required this._repository,
    this._analytics = const NoopAnalyticsService(),
  }) : super(const SignInIdle());

  final AuthRepository _repository;
  final AnalyticsService _analytics;

  /// The `method` sent with the analytics events.
  static const String googleMethod = 'google';
  static const String passwordMethod = 'password';

  Future<void> signInWithGoogle() => _signIn(
    _repository.signInWithGoogle,
    onSuccess: () => _analytics.logLogin(googleMethod),
  );

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _signIn(
    () => _repository.signInWithEmail(email: email.trim(), password: password),
    onSuccess: () => _analytics.logLogin(passwordMethod),
  );

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) => _signIn(
    () => _repository.signUpWithEmail(
      email: email.trim(),
      password: password,
      name: name?.trim(),
    ),
    onSuccess: () => _analytics.logSignUp(passwordMethod),
  );

  Future<void> sendPasswordResetEmail(String email) async {
    if (state is SignInLoading) return;
    emit(const SignInLoading());
    final trimmed = email.trim();
    final result = await _repository.sendPasswordResetEmail(trimmed);
    if (isClosed) return;
    emit(
      switch (result) {
        Success() => SignInResetEmailSent(trimmed),
        Err(:final failure) => SignInError(failure),
      },
    );
  }

  /// Taps while a request is running are ignored.
  Future<void> _signIn(
    Future<Result<AppUser>> Function() request, {
    required Future<void> Function() onSuccess,
  }) async {
    if (state is SignInLoading) return;
    emit(const SignInLoading());
    final result = await request();
    if (result.isSuccess) unawaited(onSuccess());
    if (isClosed) return;
    emit(
      switch (result) {
        Success() => const SignInSuccess(),
        Err(:final failure) => SignInError(failure),
      },
    );
  }
}
