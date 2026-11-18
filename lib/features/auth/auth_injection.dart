import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/firebase/firebase_options.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_app/features/auth/data/datasources/google_sign_in_client.dart';
import 'package:movie_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_app/features/auth/data/repositories/unavailable_auth_repository.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/domain/usecases/delete_account.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';

/// [firebaseReady] is `false` in tests and on desktop: the app then uses
/// [UnavailableAuthRepository] and everyone is a guest.
///
/// Needs `UserCloudData`, which the watchlist feature registers.
void registerAuthDependencies(GetIt sl, {required bool firebaseReady}) {
  if (firebaseReady) {
    sl
      ..registerLazySingleton<GoogleSignInClient>(
        () => GoogleSignInClientImpl(
          GoogleSignIn.instance,
          // `null` on Android (read from google-services.json) and, until
          // it is added to the options, on iOS (then read from Info.plist).
          clientId: AppFirebaseOptions.currentPlatform?.iosClientId,
        ),
      )
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => FirebaseAuthDataSource(
          FirebaseAuth.instance,
          sl<GoogleSignInClient>(),
        ),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
      );
  } else {
    sl.registerLazySingleton<AuthRepository>(
      () => const UnavailableAuthRepository(),
    );
  }

  sl
    ..registerLazySingleton<DeleteAccount>(
      () => DeleteAccount(
        auth: sl<AuthRepository>(),
        cloudData: sl<UserCloudData>(),
      ),
    )
    // A singleton: app.dart provides it above MaterialApp for every screen.
    // It lives as long as the app, so nobody needs to close it.
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(repository: sl<AuthRepository>()),
    )
    // Cubits: a new instance per screen, which closes it.
    ..registerFactory<SignInCubit>(
      () => SignInCubit(
        repository: sl<AuthRepository>(),
        analytics: sl<AnalyticsService>(),
      ),
    )
    ..registerFactory<AccountCubit>(
      () => AccountCubit(
        repository: sl<AuthRepository>(),
        deleteAccount: sl<DeleteAccount>(),
      ),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(repository: sl<AuthRepository>()),
    );
}
