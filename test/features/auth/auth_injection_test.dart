import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/features/auth/auth_injection.dart';
import 'package:movie_app/features/auth/data/repositories/unavailable_auth_repository.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:movie_app/features/watchlist/watchlist_injection.dart';

/// Without Firebase (tests, desktop) the app must still start: everyone is
/// a guest and the watchlist stays local.
void main() {
  late GetIt sl;

  setUp(() {
    sl = GetIt.asNewInstance()
      ..registerLazySingleton<AnalyticsService>(
        () => const NoopAnalyticsService(),
      );
    registerWatchlistDependencies(sl);
    registerAuthDependencies(sl, firebaseReady: false);
  });

  tearDown(() => sl.reset());

  test('uses the "unavailable" auth repository and no cloud data', () {
    expect(sl<AuthRepository>(), isA<UnavailableAuthRepository>());
    expect(sl<UserCloudData>(), isA<NoUserCloudData>());
  });

  test('the app-wide AuthCubit is a signed-out singleton', () {
    expect(identical(sl<AuthCubit>(), sl<AuthCubit>()), isTrue);
    expect(sl<AuthCubit>().state, const AuthSignedOut());
  });

  test('screen cubits are new each time', () async {
    final first = sl<SignInCubit>();
    final second = sl<SignInCubit>();
    final account = sl<AccountCubit>();
    final profile = sl<ProfileCubit>();

    expect(identical(first, second), isFalse);
    await first.close();
    await second.close();
    await account.close();
    await profile.close();
  });
}
