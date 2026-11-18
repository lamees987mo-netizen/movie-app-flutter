import 'package:equatable/equatable.dart';

/// How the user signs in. The account screens use it to show the right
/// options (only email accounts have a password to change).
enum SignInMethod {
  /// Email and password (can also have Google linked).
  email,
  google,

  /// Anything else, or not known (e.g. in tests).
  unknown,
}

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
    this.signInMethod = SignInMethod.unknown,
  });

  /// Firebase's id for the user. The cloud watchlist is stored under it.
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final SignInMethod signInMethod;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, signInMethod];
}
