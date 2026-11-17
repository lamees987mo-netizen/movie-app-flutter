import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';

/// The state of the sign-in screen's buttons.
sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => [];
}

/// Waiting for the user.
final class SignInIdle extends SignInState {
  const SignInIdle();
}

/// A request is running: the buttons are disabled.
final class SignInLoading extends SignInState {
  const SignInLoading();
}

/// Signed in (or signed up): the screen closes.
final class SignInSuccess extends SignInState {
  const SignInSuccess();
}

/// The password reset email was sent to [email].
final class SignInResetEmailSent extends SignInState {
  const SignInResetEmailSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class SignInError extends SignInState {
  const SignInError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
