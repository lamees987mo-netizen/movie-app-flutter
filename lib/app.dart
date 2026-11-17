import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/router/app_router.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The root widget. Rebuilds the [MaterialApp] when the theme or language
/// in [SettingsCubit] changes.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Created once, so navigation state survives theme/language changes.
  final GoRouter _router = createAppRouter(
    observers: sl<AnalyticsService>().navigatorObservers,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `.value`: both cubits are get_it singletons (SettingsCubit is also
    // used by Dio), so the providers must not close them.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SettingsCubit>()),
        // The signed-in user, for every screen (and the sign-in redirect).
        BlocProvider.value(value: sl<AuthCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
            // A "DEV" corner ribbon on the dev flavor, so the two installed
            // apps can't be confused. `appFlavor` comes from `--flavor`.
            builder: (context, child) => appFlavor == 'dev'
                ? Banner(
                    message: 'DEV',
                    location: BannerLocation.topEnd,
                    textDirection: TextDirection.ltr,
                    layoutDirection: TextDirection.ltr,
                    child: child,
                  )
                : child!,
          );
        },
      ),
    );
  }
}
