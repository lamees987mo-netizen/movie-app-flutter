import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';

void main() {
  group('Result', () {
    test('fold calls onSuccess with the value for Success', () {
      const Result<int> result = Success(42);

      final text = result.fold(
        onFailure: (failure) => 'failure',
        onSuccess: (value) => 'value $value',
      );

      expect(text, 'value 42');
      expect(result.isSuccess, isTrue);
    });

    test('fold calls onFailure with the failure for Err', () {
      const Result<int> result = Err(NetworkFailure());

      final failure = result.fold<Failure?>(
        onFailure: (failure) => failure,
        onSuccess: (_) => null,
      );

      expect(failure, const NetworkFailure());
      expect(result.isSuccess, isFalse);
    });

    test('supports value equality', () {
      expect(const Success(1), const Success(1));
      expect(
        const Err<int>(ServerFailure(500)),
        const Err<int>(ServerFailure(500)),
      );
      expect(
        const Err<int>(ServerFailure(500)),
        isNot(const Err<int>(ServerFailure(503))),
      );
    });
  });
}
