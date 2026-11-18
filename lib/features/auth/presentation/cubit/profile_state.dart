import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';

/// The state of the "Manage profile" screen's Save button.
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

/// Saving the new name: the button shows a spinner.
final class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

final class ProfileSaved extends ProfileState {
  const ProfileSaved();
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
