import 'package:get_it/get_it.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';

void registerSearchDependencies(GetIt sl) {
  // A new bloc every time: the Search page owns (and closes) its own.
  // Search has no data layer: it reuses the movies repository.
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(
      repository: sl<MoviesRepository>(),
      analytics: sl<AnalyticsService>(),
    ),
  );
}
