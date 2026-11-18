import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';

/// The state of the account screens' "Sign out", "Delete account" and
/// "Change password".
sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountIdle extends AccountState {
  const AccountIdle();
}

/// Signing out or deleting: the buttons are disabled.
final class AccountBusy extends AccountState {
  const AccountBusy();
}

final class AccountDeleted extends AccountState {
  const AccountDeleted();
}

/// The "change your password" email was sent to [email].
final class AccountPasswordResetSent extends AccountState {
  const AccountPasswordResetSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AccountError extends AccountState {
  const AccountError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
