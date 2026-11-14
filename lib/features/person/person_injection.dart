import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_app/features/person/data/datasources/person_remote_data_source.dart';
import 'package:movie_app/features/person/data/repositories/person_repository_impl.dart';
import 'package:movie_app/features/person/domain/repositories/person_repository.dart';
import 'package:movie_app/features/person/presentation/cubit/person_cubit.dart';

void registerPersonDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<PersonRemoteDataSource>(
      () => PersonRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<PersonRepository>(
      () => PersonRepositoryImpl(sl<PersonRemoteDataSource>()),
    )
    // A new cubit per screen: `sl<PersonCubit>(param1: personId)`.
    ..registerFactoryParam<PersonCubit, int, void>(
      (personId, _) => PersonCubit(
        personId: personId,
        repository: sl<PersonRepository>(),
      ),
    );
}
