import 'package:equatable/equatable.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

/// Who is using the app: a guest or a signed-in user.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// A guest. The whole app works; only cloud sync is off.
final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

final class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}
