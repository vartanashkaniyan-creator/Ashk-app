import '../entities/word_entity.dart';
import '../repositories/word_repository.dart';
import '../../../../core/usecases/usecase.dart';

/// Use Case برای افزودن کلمه جدید
/// 
/// رعایت اصول:
/// ۱. SRP: فقط یک مسئولیت - اعتبارسنجی و افزودن کلمه
/// ۲. DIP: وابستگی به انتزاع WordRepository، نه پیاده‌سازی
/// ۳. ISP: از کوچکترین رابط ممکن استفاده می‌کند
class AddWordUseCase implements UseCase<int, AddWordParams> {
  final WordRepository _wordRepository;

  /// تزریق وابستگی WordRepository
  const AddWordUseCase(this._wordRepository);

  /// اجرای Use Case
  ///
  /// @param params: پارامترهای لازم برای افزودن کلمه
  /// @return شناسه یکتای کلمه ذخیره شده
  /// @throws WordValidationException در صورت نامعتبر بودن داده‌ها
  /// @throws WordRepositoryException در صورت خطای دیتابیس
  @override
  Future<int> execute(AddWordParams params) async {
    // اعتبارسنجی داده‌های ورودی
    _validateInput(params);

    // ایجاد موجودیت کلمه
    final wordEntity = WordEntity(
      english: params.english,
      persian: params.persian,
      exampleSentence: params.exampleSentence,
      difficultyLevel: params.difficultyLevel,
    );

    // اعتبارسنجی موجودیت
    if (!wordEntity.isValid) {
      throw const WordValidationException('داده‌های کلمه معتبر نیستند');
    }

    // ذخیره کلمه از طریق ریپازیتوری
    try {
      final wordId = await _wordRepository.addWord(wordEntity);
      return wordId;
    } on DuplicateWordException {
      // خطای خاص تکراری بودن را دوباره throw می‌کنیم
      rethrow;
    } catch (error) {
      // خطاهای عمومی را wrap می‌کنیم
      throw WordUseCaseException(
        'خطا در افزودن کلمه',
        innerError: error,
      );
    }
  }

  /// اعتبارسنجی اولیه پارامترهای ورودی
  void _validateInput(AddWordParams params) {
    final errors = <String>[];

    if (params.english.trim().isEmpty) {
      errors.add('متن انگلیسی نمی‌تواند خالی باشد');
    } else if (params.english.trim().length > 100) {
      errors.add('متن انگلیسی نمی‌تواند بیش از ۱۰۰ کاراکتر باشد');
    }

    if (params.persian.trim().isEmpty) {
      errors.add('معنی فارسی نمی‌تواند خالی باشد');
    } else if (params.persian.trim().length > 200) {
      errors.add('معنی فارسی نمی‌تواند بیش از ۲۰۰ کاراکتر باشد');
    }

    if (params.difficultyLevel < 1 || params.difficultyLevel > 5) {
      errors.add('سطح دشواری باید بین ۱ تا ۵ باشد');
    }

    if (params.exampleSentence != null &&
        params.exampleSentence!.trim().length > 500) {
      errors.add('جمله مثال نمی‌تواند بیش از ۵۰۰ کاراکتر باشد');
    }

    if (errors.isNotEmpty) {
      throw WordValidationException(
        'خطاهای اعتبارسنجی: ${errors.join(', ')}',
        validationErrors: errors,
      );
    }
  }
}

/// پارامترهای مورد نیاز برای افزودن کلمه
/// 
/// رعایت ISP: فقط پارامترهای لازم برای این Use Case خاص
class AddWordParams {
  final String english;
  final String persian;
  final String? exampleSentence;
  final int difficultyLevel;

  const AddWordParams({
    required this.english,
    required this.persian,
    this.exampleSentence,
    this.difficultyLevel = 1,
  });

  /// ایجاد پارامترها از Map
  factory AddWordParams.fromMap(Map<String, dynamic> map) {
    return AddWordParams(
      english: map['english'] as String,
      persian: map['persian'] as String,
      exampleSentence: map['exampleSentence'] as String?,
      difficultyLevel: map['difficultyLevel'] as int? ?? 1,
    );
  }

  /// تبدیل به Map برای نمایش یا انتقال
  Map<String, dynamic> toMap() {
    return {
      'english': english,
      'persian': persian,
      if (exampleSentence != null) 'exampleSentence': exampleSentence,
      'difficultyLevel': difficultyLevel,
    };
  }

  @override
  String toString() {
    return 'AddWordParams(english: $english, persian: $persian, '
        'difficultyLevel: $difficultyLevel)';
  }
}

/// ============================
/// خطاهای اختصاصی Use Case
/// ============================

/// خطای پایه برای Use Caseها
abstract class WordUseCaseException implements Exception {
  final String message;
  final dynamic innerError;

  const WordUseCaseException(this.message, {this.innerError});

  @override
  String toString() => 'WordUseCaseException: $message${innerError != null ? ' -> $innerError' : ''}';
}

/// خطای اعتبارسنجی داده‌های کلمه
class WordValidationException extends WordUseCaseException {
  final List<String> validationErrors;

  const WordValidationException(
    String message, {
    this.validationErrors = const [],
  }) : super(message);

  @override
  String toString() => 'WordValidationException: $message${validationErrors.isNotEmpty ? ' ($validationErrors)' : ''}';
}
