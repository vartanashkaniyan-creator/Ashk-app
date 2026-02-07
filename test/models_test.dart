// test/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models.dart';

void main() {
  group('Word Model', () {
    // DRY: ایجاد fixture مشترک برای تست‌ها
    Word createTestWord({
      int id = 1,
      String english = 'hello',
      String persian = 'سلام',
    }) {
      return Word(
        id: id,
        english: english,
        persian: persian,
        example: 'Hello world',
        createdAt: DateTime(2024, 1, 1),
        nextReview: DateTime(2024, 1, 2),
        interval: 1,
        easeFactor: 2.5,
        reviewCount: 0,
      );
    }

    test('should create a Word with correct properties', () {
      // Arrange
      final word = createTestWord();

      // Act & Assert
      expect(word.id, 1);
      expect(word.english, 'hello');
      expect(word.persian, 'سلام');
      expect(word.example, 'Hello world');
      expect(word.interval, 1);
      expect(word.easeFactor, 2.5);
      expect(word.reviewCount, 0);
    });

    test('copyWith should create a new Word with updated fields', () {
      // Arrange
      final original = createTestWord();

      // Act
      final copied = original.copyWith(
        english: 'test',
        reviewCount: 5,
      );

      // Assert
      expect(copied.id, original.id); // LSP: باید جایگزین‌پذیر باشد
      expect(copied.english, 'test');
      expect(copied.persian, original.persian);
      expect(copied.reviewCount, 5);
      expect(copied.easeFactor, original.easeFactor);
    });

    test('reviewStatus should return correct status for overdue', () {
      // Arrange
      final word = createTestWord().copyWith(
        nextReview: DateTime(2023, 12, 31), // گذشته
      );

      // Act
      final status = word.reviewStatus;

      // Assert
      expect(status, ReviewStatus.overdue);
    });

    test('reviewStatus should return correct status for due soon', () {
      // Arrange
      final now = DateTime.now();
      final word = createTestWord().copyWith(
        nextReview: now.add(const Duration(days: 1)),
      );

      // Act
      final status = word.reviewStatus;

      // Assert
      expect(status, ReviewStatus.dueSoon);
    });

    test('reviewStatus should return correct status for up to date', () {
      // Arrange
      final now = DateTime.now();
      final word = createTestWord().copyWith(
        nextReview: now.add(const Duration(days: 10)),
      );

      // Act
      final status = word.reviewStatus;

      // Assert
      expect(status, ReviewStatus.upToDate);
    });

    test('equality operator should work correctly', () {
      // Arrange
      final word1 = createTestWord(id: 1, english: 'test');
      final word2 = createTestWord(id: 1, english: 'test');
      final word3 = createTestWord(id: 2, english: 'different');

      // Act & Assert
      expect(word1 == word2, isTrue);
      expect(word1 == word3, isFalse);
    });

    test('hashCode should be consistent with equality', () {
      // Arrange
      final word1 = createTestWord(id: 1, english: 'test');
      final word2 = createTestWord(id: 1, english: 'test');

      // Act & Assert
      expect(word1.hashCode, word2.hashCode);
    });
  });

  group('SrsCalculationParams', () {
    test('calculateNewInterval should return 1 for quality < 3', () {
      // Arrange
      const params = SrsCalculationParams(
        currentInterval: 10,
        currentEaseFactor: 2.0,
        quality: 2, // کمتر از 3
      );

      // Act
      final result = params.calculateNewInterval();

      // Assert
      expect(result, 1);
    });

    test('calculateNewInterval should calculate correctly for quality >= 3', () {
      // Arrange
      const params = SrsCalculationParams(
        currentInterval: 10,
        currentEaseFactor: 2.0,
        quality: 4,
      );

      // Act
      final result = params.calculateNewInterval();

      // Assert
      expect(result, 20); // 10 * 2.0
    });

    test('calculateNewInterval should clamp between 1 and 365', () {
      // Arrange
      const params = SrsCalculationParams(
        currentInterval: 200,
        currentEaseFactor: 3.0, // می‌شود 600
        quality: 5,
      );

      // Act
      final result = params.calculateNewInterval();

      // Assert
      expect(result, 365); // محدود به 365
    });

    test('calculateNewEaseFactor should clamp between 1.3 and 2.5', () {
      // Arrange
      const params = SrsCalculationParams(
        currentInterval: 10,
        currentEaseFactor: 1.0,
        quality: 5,
      );

      // Act
      final result = params.calculateNewEaseFactor();

      // Assert
      expect(result, 1.3); // باید محدود شود
    });

    test('calculateNewEaseFactor should calculate correctly', () {
      // Arrange
      const params = SrsCalculationParams(
        currentInterval: 10,
        currentEaseFactor: 2.5,
        quality: 3,
      );

      // Act
      final result = params.calculateNewEaseFactor();

      // Assert
      expect(result, greaterThan(2.4));
      expect(result, lessThan(2.6));
    });
  });

  group('Result', () {
    test('Result.success should create successful result', () {
      // Arrange & Act
      const result = Result<String>.success('test data');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, 'test data');
      expect(result.error, isNull);
      expect(result.hasError, isFalse);
    });

    test('Result.failure should create failed result', () {
      // Arrange & Act
      const result = Result<String>.failure('error message');

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.error, 'error message');
      expect(result.hasError, isTrue);
    });
  });

  group('Failure', () {
    test('WordNotFoundFailure should have correct message', () {
      // Arrange & Act
      final failure = WordNotFoundFailure(123);

      // Assert
      expect(failure.message, 'Word with id 123 not found');
      expect(failure.toString(), 'Word with id 123 not found');
    });

    test('DuplicateWordFailure should have correct message', () {
      // Arrange & Act
      final failure = DuplicateWordFailure('test');

      // Assert
      expect(failure.message, '"test" already exists');
    });

    test('InvalidWordDataFailure should have correct message', () {
      // Arrange & Act
      final failure = InvalidWordDataFailure('english');

      // Assert
      expect(failure.message, 'Invalid value for english');
    });

    test('All failures should be subtypes of Failure', () {
      // LSP: همه باید جایگزین Failure پایه شوند
      final failures = [
        WordNotFoundFailure(1),
        DuplicateWordFailure('test'),
        InvalidWordDataFailure('field'),
      ];

      for (final failure in failures) {
        expect(failure, isA<Failure>());
      }
    });
  });

  group('Value Objects', () {
    test('SearchParams should create with defaults', () {
      // Arrange & Act
      const params = SearchParams(query: 'test');

      // Assert
      expect(params.query, 'test');
      expect(params.matchEnglish, isTrue);
      expect(params.matchPersian, isTrue);
      expect(params.matchExample, isFalse);
    });

    test('SearchParams.copyWith should update correctly', () {
      // Arrange
      const original = SearchParams(query: 'test');

      // Act
      final updated = original.copyWith(
        query: 'updated',
        matchExample: true,
      );

      // Assert
      expect(updated.query, 'updated');
      expect(updated.matchExample, isTrue);
      expect(updated.matchEnglish, original.matchEnglish); // بدون تغییر باقی می‌ماند
    });

    test('AddWordParams should create correctly', () {
      // Arrange & Act
      const params = AddWordParams(
        english: 'hello',
        persian: 'سلام',
        example: 'example',
      );

      // Assert
      expect(params.english, 'hello');
      expect(params.persian, 'سلام');
      expect(params.example, 'example');
    });
  });
}
