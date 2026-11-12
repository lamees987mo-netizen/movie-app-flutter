import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';

void registerSettingsDependencies(GetIt sl) {
  // A singleton: the whole app shares one instance. app.dart provides it to
  // the widget tree, and the Dio language interceptor reads its locale.
  // It lives as long as the app, so nobody needs to close it.
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(sl<Box<dynamic>>(instanceName: HiveBoxes.settings)),
  );
}
