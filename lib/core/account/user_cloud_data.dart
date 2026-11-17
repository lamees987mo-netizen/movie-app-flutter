import 'package:movie_app/core/result/result.dart';

/// The user's data kept in the cloud (today: the synced watchlist).
///
/// Lives in `core` so two features can share it without importing each
/// other: the watchlist feature implements it, and the auth feature's
/// "Delete account" uses it. Google Play requires that deleting an account
/// also deletes the data stored for it.
abstract interface class UserCloudData {
  /// Deletes everything stored in the cloud for the user [uid].
  Future<Result<void>> deleteCloudData(String uid);

  /// Uploads this device's copy again. Called when deleting the account
  /// fails after its cloud data was already deleted, so nothing is lost.
  /// Never throws.
  Future<void> restoreCloudData(String uid);
}

/// Used when the app runs without Firebase: there is no cloud data.
class NoUserCloudData implements UserCloudData {
  const NoUserCloudData();

  @override
  Future<Result<void>> deleteCloudData(String uid) async => const Success(null);

  @override
  Future<void> restoreCloudData(String uid) async {}
}
