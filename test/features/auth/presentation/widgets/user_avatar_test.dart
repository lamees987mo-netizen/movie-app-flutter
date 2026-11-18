import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/widgets/user_avatar.dart';

import '../../../movies/movies_test_helpers.dart';

void main() {
  group('initialsOf', () {
    final cases = <AppUser, String>{
      const AppUser(uid: '1', displayName: 'Lamees Saad'): 'LS',
      const AppUser(uid: '2', displayName: 'lamees'): 'L',
      const AppUser(uid: '3', displayName: 'Lamees Mabrouk Saad'): 'LM',
      const AppUser(uid: '4', displayName: 'لاميس سعد'): 'لس',
      const AppUser(uid: '5', displayName: '  ', email: 'ann@x.co'): 'A',
      const AppUser(uid: '6', email: 'bob@x.co'): 'B',
      const AppUser(uid: '7'): '?',
    };
    for (final MapEntry(key: user, value: initials) in cases.entries) {
      test('${user.displayName ?? user.email} -> $initials', () {
        expect(UserAvatar.initialsOf(user), initials);
      });
    }
  });

  testWidgets('shows the initials when there is no photo', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const UserAvatar(
          user: AppUser(uid: '1', displayName: 'Lamees Saad'),
        ),
      ),
    );

    expect(find.text('LS'), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.foregroundImage, isNull);
  });

  testWidgets('a guest gets a person icon', (tester) async {
    await tester.pumpWidget(wrapWithApp(const UserAvatar(user: null)));

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
