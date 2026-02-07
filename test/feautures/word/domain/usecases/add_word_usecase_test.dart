import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/features/word/domain/entities/word_entity.dart';
import 'package:english_learning_app/features/word/domain/repositories/word_repository.dart';
import 'package:english_learning_app/features/word/domain/usecases/add_word_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Mock ریپازیتوری برای تست
class MockWordRepository extends Mock implements WordRepository {}

// Fake WordEntity برای ثبت fallback value
class FakeWordEntity extends Fake implements WordEntity {
  @override
  final String english;
  @override
  final String persian;
  @override
  final String? exampleSentence;
  @override
  final int reviewCount;
  @override
  final int difficultyLevel;
  @override
  final DateTime? nextReviewDate;
  @override
  final int reviewInterval;

  FakeWordEntity({
    required this.english,
    required this.persian,
    this.exampleSentence,
    this.reviewCount = 0,
    this.difficultyLevel = 1,
    this.nextReviewDate,
    this.reviewInterval = 24,
  });

  @override
  bool get isValid => english.isNotEmpty && persian.isNotEmpty;

  @override
  DateTime calculateNextReviewDate(bool answeredCorrectly) => DateTime.now();

  @override
  List<Object?> get props => [english, persian];
}

void main() {
  late MockWordRepository mockRepository;
  late AddWordUseCase addWordUseCase;

  setUpAll(() {
    // ثبت fallback value برای WordEntity (ضروری برای mocktail)
    registerFallbackValue(FakeWordEntity(english: 'test', persian: 'تست'));
  });

  setUp(() {
    mockRepository = MockWordRepository();
    addWordUseCase = AddWordUseCase(mockRepository);
  });

  group('AddWordUseCase Tests', () {
    const testEnglish = 'hello';
    const testPersian = 'سلام';
    const testExample = 'Hello world!';
    const testDifficulty = 2;
    const testWordId = 1;

    // تست موفقیت‌آمیز افزودن کلمه
    test('should add word successfully when data is valid', () async {
      // Arrange
      when(() => mockRepository.addWord(any()))
          .thenAnswer((_) async => testWordId);

      // Act
      final result = await addWordUseCase.execute(
        english: testEnglish,
        persian: testPersian,
        exampleSentence: testExample,
        difficultyLevel: testDifficulty,
      );

      // Assert
      expect(result, testWordId);
      verify(() => mockRepository.addWord(any())).called(1);
    });

    // تست خطای اعتبارسنجی - متن انگلیسی خالی
    test('should throw exception when english text is empty', () {
      // Act & Assert
      expect(
        () => addWordUseCase.execute(
          english: '',
          persian: testPersian,
        ),
        throwsA(isA<AddWordException>()),
      );
      verifyNever(() => mockRepository.addWord(any()));
    });

    // تست خطای اعتبارسنجی - متن فارسی خالی
    test('should throw exception when persian text is empty', () {
      // Act & Assert
      expect(
        () => addWordUseCase.execute(
          english: testEnglish,
          persian: '',
        ),
        throwsA(isA<AddWordException>()),
      );
      verifyNever(() => mockRepository.addWord(any()));
    });

    // تست خطای اعتبارسنجی - سطح دشواری نامعتبر
    test('should throw exception when difficulty level is invalid', () {
      // Act & Assert
      expect(
        () => addWordUseCase.execute(
          english: testEnglish,
          persian: testPersian,
          difficultyLevel: 6, // نامعتبر (باید ۱-۵ باشد)
        ),
        throwsA(isA<AddWordException>()),
      );
      verifyNever(() => mockRepository.addWord(any()));
    });

    // تست خطای تکراری بودن کلمه
    test('should handle duplicate word error from repository', () {
      // Arrange
      when(() => mockRepository.addWord(any())).thenThrow(
        const DuplicateWordException('hello'),
      );

      // Act & Assert
      expect(
        () => addWordUseCase.execute(
          english: testEnglish,
          persian: testPersian,
        ),
        throwsA(isA<AddWordException>()),
      );
    });

    // تست خطای عمومی ریپازیتوری
    test('should handle generic repository error', () {
      // Arrange
      when(() => mockRepository.addWord(any()))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => addWordUseCase.execute(
          english: testEnglish,
          persian: testPersian,
        ),
        throwsA(isA<AddWordException>()),
      );
    });

    // تست trim کردن فاصله‌های اضافی
    test('should trim whitespace from inputs', () async {
      // Arrange
      when(() => mockRepository.addWord(any()))
          .thenAnswer((invocation) async {
        final word = invocation.positionalArguments[0] as WordEntity;
        expect(word.english, testEnglish); // بدون فاصله اضافی
        expect(word.persian, testPersian); // بدون فاصله اضافی
        return testWordId;
      });

      // Act
      await addWordUseCase.execute(
        english: '  $testEnglish  ', // با فاصله اضافی
        persian: '$testPersian  ', // با فاصله اضافی
      );

      // Assert
      verify(() => mockRepository.addWord(any())).called(1);
    });
  });
}
