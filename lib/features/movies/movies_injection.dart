import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';

void registerMoviesDependencies(GetIt sl) {
  // Data and domain: one shared instance, created on first use.
  sl
    ..registerLazySingleton<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<MoviesLocalDataSource>(
      () => MoviesLocalDataSourceImpl(
        sl<Box<dynamic>>(instanceName: HiveBoxes.homeCache),
      ),
    )
    ..registerLazySingleton<MoviesRepository>(
      () => MoviesRepositoryImpl(
        sl<MoviesRemoteDataSource>(),
        localDataSource: sl<MoviesLocalDataSource>(),
        languageCode: () => sl<SettingsCubit>().state.locale.languageCode,
      ),
    )
    ..registerLazySingleton<GetMovieDetails>(
      () => GetMovieDetails(sl<MoviesRepository>()),
    )
    // Cubits: a new instance every time, because each screen owns (and
    // closes) its own. `registerFactoryParam` lets the caller pass one
    // value: `sl<MovieSectionCubit>(param1: MovieCategory.trending)`.
    ..registerFactoryParam<MovieSectionCubit, MovieCategory, void>(
      (category, _) => MovieSectionCubit(
        category: category,
        repository: sl<MoviesRepository>(),
      ),
    )
    ..registerFactoryParam<SeeAllCubit, MovieCategory, void>(
      (category, _) => SeeAllCubit(
        category: category,
        repository: sl<MoviesRepository>(),
      ),
    )
    ..registerFactoryParam<MovieDetailsCubit, int, void>(
      (movieId, _) => MovieDetailsCubit(
        movieId: movieId,
        getMovieDetails: sl<GetMovieDetails>(),
      ),
    );
}
