import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';

import '../../../movies/movies_test_helpers.dart';

typedef Json = Map<String, dynamic>;

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollection extends Mock implements CollectionReference<Json> {}

class MockDocument extends Mock implements DocumentReference<Json> {}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Json> {}

class MockQueryDocument extends Mock implements QueryDocumentSnapshot<Json> {}

class MockBatch extends Mock implements WriteBatch {}

/// Firestore is mocked with mocktail (`fake_cloud_firestore` can't be
/// added: it conflicts with equatable 3). These tests check the paths, the
/// stored JSON and the error mapping.
void main() {
  late MockFirestore firestore;
  late MockCollection users;
  late MockDocument userDocument;
  late MockCollection watchlist;
  late MockDocument movieDocument;
  late MockBatch batch;
  late FirestoreWatchlistDataSource dataSource;

  final entry = SavedMovieModel(
    movie: MovieModel.fromEntity(tMovie1),
    addedAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(MockDocument());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    firestore = MockFirestore();
    users = MockCollection();
    userDocument = MockDocument();
    watchlist = MockCollection();
    movieDocument = MockDocument();
    batch = MockBatch();
    dataSource = FirestoreWatchlistDataSource(firestore);

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDocument);
    when(() => userDocument.collection('watchlist')).thenReturn(watchlist);
    when(() => watchlist.doc(any())).thenReturn(movieDocument);
    when(() => firestore.batch()).thenReturn(batch);
    when(() => batch.commit()).thenAnswer((_) async {});
  });

  MockQuerySnapshot snapshotOf(List<Json> documents) {
    final snapshot = MockQuerySnapshot();
    final docs = [
      for (final json in documents)
        () {
          final document = MockQueryDocument();
          when(document.data).thenReturn(json);
          when(() => document.reference).thenReturn(movieDocument);
          return document;
        }(),
    ];
    when(() => snapshot.docs).thenReturn(docs);
    return snapshot;
  }

  test('getAll reads users/{uid}/watchlist', () async {
    final snapshot = snapshotOf([entry.toJson()]);
    when(() => watchlist.get()).thenAnswer((_) async => snapshot);

    final result = await dataSource.getAll('u1');

    expect(result.single.movie.id, tMovie1.id);
    expect(result.single.addedAt, DateTime(2024));
  });

  test('put writes the entry JSON under the movie id', () async {
    when(() => movieDocument.set(any())).thenAnswer((_) async {});

    await dataSource.put('u1', entry);

    verify(() => watchlist.doc('${tMovie1.id}')).called(1);
    verify(() => movieDocument.set(entry.toJson())).called(1);
  });

  test('putAll writes all entries in one batch', () async {
    await dataSource.putAll('u1', [entry, entry]);

    verify(() => batch.set(movieDocument, entry.toJson())).called(2);
    verify(() => batch.commit()).called(1);
  });

  test('putAll with nothing to write sends no batch', () async {
    await dataSource.putAll('u1', []);

    verifyNever(() => firestore.batch());
  });

  test('remove deletes the movie document', () async {
    when(() => movieDocument.delete()).thenAnswer((_) async {});

    await dataSource.remove('u1', 7);

    verify(() => watchlist.doc('7')).called(1);
    verify(() => movieDocument.delete()).called(1);
  });

  test('removeAll deletes every document in a batch', () async {
    final snapshot = snapshotOf([entry.toJson(), entry.toJson()]);
    when(() => watchlist.get()).thenAnswer((_) async => snapshot);

    await dataSource.removeAll('u1');

    verify(() => batch.delete(movieDocument)).called(2);
    verify(() => batch.commit()).called(1);
  });

  group('errors', () {
    test('"unavailable" becomes a NetworkException', () {
      when(() => watchlist.get()).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(dataSource.getAll('u1'), throwsA(isA<NetworkException>()));
    });

    test('other Firebase codes become a ServerException', () {
      when(() => watchlist.get()).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        dataSource.getAll('u1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'permission-denied',
          ),
        ),
      );
    });

    test('a document with the wrong shape becomes a ServerException', () {
      final snapshot = snapshotOf([
        {'id': 'not a number'},
      ]);
      when(() => watchlist.get()).thenAnswer((_) async => snapshot);

      expect(dataSource.getAll('u1'), throwsA(isA<ServerException>()));
    });
  });
}
