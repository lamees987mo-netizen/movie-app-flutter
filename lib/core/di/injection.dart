import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/config/env.dart';
import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/movies/movies_injection.dart';
import 'package:movie_app/features/person/person_injection.dart';
import 'package:movie_app/features/search/search_injection.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/settings_injection.dart';
import 'package:movie_app/features/watchlist/watchlist_injection.dart';

/// The service locator: `sl<MoviesRepository>()` returns the registered
/// instance from anywhere in the app.
final GetIt sl = GetIt.instance;

/// Registers shared services, then lets each feature register its own.
///
/// Call after `HiveBoxes.init()`, because the boxes must already be open.
void initDependencies() {
  sl
    ..registerLazySingleton<Dio>(
      () => createDioClient(
        token: Env.tmdbToken,
        // Read on every request, so a language change applies right away.
        languageCode: () => sl<SettingsCubit>().state.locale.languageCode,
      ),
    )
    ..registerLazySingleton<Connectivity>(Connectivity.new);

  // Each box is registered by name: sl<Box<dynamic>>(instanceName: ...).
  for (final name in [
    HiveBoxes.watchlist,
    HiveBoxes.homeCache,
    HiveBoxes.settings,
  ]) {
    sl.registerSingleton<Box<dynamic>>(
      Hive.box<dynamic>(name),
      instanceName: name,
    );
  }

  registerMoviesDependencies(sl);
  registerPersonDependencies(sl);
  registerSearchDependencies(sl);
  registerWatchlistDependencies(sl);
  registerSettingsDependencies(sl);
}
