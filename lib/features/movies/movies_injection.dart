import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';

void registerMoviesDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<MoviesRepository>(
      () => MoviesRepositoryImpl(sl<MoviesRemoteDataSource>()),
    );

  // Cubits (registered with registerFactory) are added by the movies feature.
}
