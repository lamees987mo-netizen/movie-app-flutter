import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';

void registerWatchlistDependencies(GetIt sl) {
  // Data: one shared instance, created on first use.
  sl
    ..registerLazySingleton<WatchlistLocalDataSource>(
      () => WatchlistLocalDataSourceImpl(
        sl<Box<dynamic>>(instanceName: HiveBoxes.watchlist),
      ),
    )
    ..registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(sl<WatchlistLocalDataSource>()),
    )
    // Cubits: a new instance per screen, which closes it.
    ..registerFactory<WatchlistCubit>(
      () => WatchlistCubit(repository: sl<WatchlistRepository>()),
    )
    // `sl<WatchlistToggleCubit>(param1: movie)`.
    ..registerFactoryParam<WatchlistToggleCubit, Movie, void>(
      (movie, _) => WatchlistToggleCubit(
        movie: movie,
        repository: sl<WatchlistRepository>(),
      ),
    );
}
