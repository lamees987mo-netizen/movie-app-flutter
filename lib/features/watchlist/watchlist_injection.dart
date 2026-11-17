import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:movie_app/features/watchlist/data/repositories/synced_watchlist_repository.dart';
import 'package:movie_app/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:movie_app/features/watchlist/data/sync/watchlist_sync_service.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';

/// [cloudSync] is `true` when Firebase is running: the watchlist is then
/// also saved to the signed-in user's Firestore account. Without Firebase
/// (tests, desktop) it stays local only.
void registerWatchlistDependencies(GetIt sl, {bool cloudSync = false}) {
  // Data: one shared instance, created on first use.
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(
      sl<Box<dynamic>>(instanceName: HiveBoxes.watchlist),
    ),
  );

  if (cloudSync) {
    sl
      ..registerLazySingleton<WatchlistRemoteDataSource>(
        () => FirestoreWatchlistDataSource(FirebaseFirestore.instance),
      )
      ..registerLazySingleton<WatchlistSyncService>(
        () => WatchlistSyncService(
          local: sl<WatchlistLocalDataSource>(),
          remote: sl<WatchlistRemoteDataSource>(),
        ),
      )
      // The same object, seen by "Delete account" as the user's cloud data.
      ..registerLazySingleton<UserCloudData>(
        () => sl<WatchlistSyncService>(),
      )
      // The screens get the local repository wrapped with sync.
      ..registerLazySingleton<WatchlistRepository>(
        () => SyncedWatchlistRepository(
          WatchlistRepositoryImpl(sl<WatchlistLocalDataSource>()),
          sl<WatchlistSyncService>(),
        ),
      );
  } else {
    sl
      ..registerLazySingleton<UserCloudData>(() => const NoUserCloudData())
      ..registerLazySingleton<WatchlistRepository>(
        () => WatchlistRepositoryImpl(sl<WatchlistLocalDataSource>()),
      );
  }

  sl
    // Cubits: a new instance per screen, which closes it.
    ..registerFactory<WatchlistCubit>(
      () => WatchlistCubit(repository: sl<WatchlistRepository>()),
    )
    // `sl<WatchlistToggleCubit>(param1: movie)`.
    ..registerFactoryParam<WatchlistToggleCubit, Movie, void>(
      (movie, _) => WatchlistToggleCubit(
        movie: movie,
        repository: sl<WatchlistRepository>(),
        analytics: sl<AnalyticsService>(),
      ),
    );
}
