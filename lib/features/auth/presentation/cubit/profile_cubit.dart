import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_state.dart';

export 'profile_state.dart';

/// Saves a new display name on the "Manage profile" screen.
///
/// The new name reaches the rest of the app through `AuthCubit` (Firebase
/// emits the changed user), so this cubit only tracks the Save button.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._repository}) : super(const ProfileIdle());

  final AuthRepository _repository;

  /// Extra spaces are removed first. Taps while saving are ignored.
  Future<void> saveName(String name) async {
    if (state is ProfileSaving) return;
    emit(const ProfileSaving());
    final result = await _repository.updateDisplayName(name.trim());
    if (isClosed) return;
    emit(
      switch (result) {
        Success() => const ProfileSaved(),
        Err(:final failure) => ProfileError(failure),
      },
    );
  }
}
