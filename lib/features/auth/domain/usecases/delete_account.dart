import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';

/// Deletes the user's cloud data, then their account.
///
/// A use case (and not just a repository call) because it has real logic
/// that touches two features:
///
/// 1. The cloud data must go **first**: the security rules only let a
///    signed-in user delete their data, so after the account is gone
///    nobody could delete it any more.
/// 2. If deleting the account then fails (most often Firebase's
///    "requires recent login"), the data is uploaded again from this
///    device, so the user loses nothing and can simply try again.
class DeleteAccount {
  DeleteAccount({required this._auth, required this._cloudData});

  final AuthRepository _auth;
  final UserCloudData _cloudData;

  Future<Result<void>> call() async {
    final user = _auth.currentUser;
    if (user == null) return const Err(AuthFailure(AuthError.unknown));

    final dataDeleted = await _cloudData.deleteCloudData(user.uid);
    if (dataDeleted case Err(:final failure)) {
      // Part of it may already be deleted (or will be, once a pending
      // offline delete is sent), so put everything back.
      await _cloudData.restoreCloudData(user.uid);
      return Err(failure);
    }

    final accountDeleted = await _auth.deleteAccount();
    if (accountDeleted is Err) {
      await _cloudData.restoreCloudData(user.uid);
    }
    return accountDeleted;
  }
}
