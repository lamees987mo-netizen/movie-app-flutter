import 'package:equatable/equatable.dart';

/// The signed-in user, as the app sees it.
///
/// The app's own class instead of Firebase's `User`, so the domain and the
/// screens don't depend on Firebase (and tests can create one easily).
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Firebase's id for the user. The cloud watchlist is stored under it.
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
