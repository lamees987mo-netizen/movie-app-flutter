import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_panel.dart';

import '../../../movies/movies_test_helpers.dart';

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late MockSettingsCubit cubit;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
  });

  setUp(() {
    cubit = MockSettingsCubit();
    when(() => cubit.state).thenReturn(const SettingsState());
    when(() => cubit.setThemeMode(any())).thenAnswer((_) async {});
    when(() => cubit.setLocale(any())).thenAnswer((_) async {});
  });

  /// Like `app.dart`, the cubit is provided above the page.
  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: wrapWithApp(const Scaffold(body: SettingsPanel())),
      ),
    );
  }

  SegmentedButton<T> segmentedButton<T>(WidgetTester tester) =>
      tester.widget<SegmentedButton<T>>(find.byType(SegmentedButton<T>));

  testWidgets('shows the theme and language choices', (tester) async {
    await pumpPage(tester);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('selects the current theme and language', (tester) async {
    when(() => cubit.state).thenReturn(
      const SettingsState(themeMode: ThemeMode.dark, locale: Locale('ar')),
    );
    await pumpPage(tester);

    expect(segmentedButton<ThemeMode>(tester).selected, {ThemeMode.dark});
    expect(segmentedButton<String>(tester).selected, {'ar'});
  });

  testWidgets('tapping Dark sets the dark theme', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Dark'));

    verify(() => cubit.setThemeMode(ThemeMode.dark)).called(1);
  });

  testWidgets('tapping Arabic switches the language', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('العربية'));

    verify(() => cubit.setLocale(const Locale('ar'))).called(1);
  });
}
