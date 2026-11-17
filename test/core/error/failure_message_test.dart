import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  final expected = <Failure, String>{
    const NetworkFailure(): en.commonErrorNetwork,
    const ServerFailure(500): en.commonErrorServer,
    const ServerFailure(): en.commonErrorServer,
    const NotFoundFailure(): en.commonNotFound,
    const CacheFailure(): en.commonCacheError,
    const UnknownFailure(): en.commonErrorGeneric,
  };

  for (final MapEntry(key: failure, value: message) in expected.entries) {
    test('${failure.runtimeType}${failure.props} -> "$message"', () {
      expect(failure.message(en), message);
    });
  }

  test('every failure type has its own message', () {
    final messages = {
      for (final failure in expected.keys) failure.message(en),
    };
    // Two ServerFailures share one message: 6 failures, 5 messages.
    expect(messages, hasLength(5));
  });

  test('uses the given language', () {
    expect(const NetworkFailure().message(ar), ar.commonErrorNetwork);
    expect(
      const NetworkFailure().message(ar),
      isNot(const NetworkFailure().message(en)),
    );
  });

  group('AuthFailure', () {
    final authMessages = <AuthError, String>{
      AuthError.invalidCredentials: en.authErrorInvalidCredentials,
      AuthError.emailAlreadyInUse: en.authErrorEmailInUse,
      AuthError.weakPassword: en.authErrorWeakPassword,
      AuthError.invalidEmail: en.authErrorInvalidEmail,
      AuthError.userDisabled: en.authErrorUserDisabled,
      AuthError.tooManyRequests: en.authErrorTooManyRequests,
      AuthError.requiresRecentLogin: en.authErrorRequiresRecentLogin,
      AuthError.cancelled: en.authErrorCancelled,
      AuthError.unavailable: en.authErrorUnavailable,
      AuthError.unknown: en.commonErrorGeneric,
    };

    test('covers every AuthError', () {
      expect(authMessages.keys, unorderedEquals(AuthError.values));
    });

    for (final MapEntry(key: error, value: message) in authMessages.entries) {
      test('$error -> "$message"', () {
        expect(AuthFailure(error).message(en), message);
      });
    }

    test('is translated', () {
      expect(
        const AuthFailure(AuthError.cancelled).message(ar),
        ar.authErrorCancelled,
      );
    });
  });
}
