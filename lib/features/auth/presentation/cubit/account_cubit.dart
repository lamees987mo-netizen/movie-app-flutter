import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/domain/usecases/delete_account.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_state.dart';

export 'account_state.dart';

/// "Sign out", "Delete account" and "Change password" on the account
/// screens.
///
/// After either one, `AuthCubit` sees the user disappear and the screen
/// switches to the guest view by itself.
class AccountCubit extends Cubit<AccountState> {
  AccountCubit({required this._repository, required this._deleteAccount})
    : super(const AccountIdle());

  final AuthRepository _repository;
  final DeleteAccount _deleteAccount;

  Future<void> signOut() =>
      _run(_repository.signOut, onSuccess: const AccountIdle());

  Future<void> deleteAccount() =>
      _run(_deleteAccount.call, onSuccess: const AccountDeleted());

  /// "Change password": Firebase emails [email] a link to set a new one,
  /// so the app never handles the new password itself.
  Future<void> sendPasswordReset(String email) => _run(
    () => _repository.sendPasswordResetEmail(email),
    onSuccess: AccountPasswordResetSent(email),
  );

  /// Taps while an action is running are ignored.
  Future<void> _run(
    Future<Result<void>> Function() action, {
    required AccountState onSuccess,
  }) async {
    if (state is AccountBusy) return;
    emit(const AccountBusy());
    final result = await action();
    if (isClosed) return;
    emit(
      switch (result) {
        Success() => onSuccess,
        Err(:final failure) => AccountError(failure),
      },
    );
  }
}
