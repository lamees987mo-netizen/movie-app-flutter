import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';

void registerSettingsDependencies(GetIt sl) {
  // A factory: the single instance used by the app is created (and closed)
  // by the BlocProvider in app.dart.
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<Box<dynamic>>(instanceName: HiveBoxes.settings)),
  );
}
