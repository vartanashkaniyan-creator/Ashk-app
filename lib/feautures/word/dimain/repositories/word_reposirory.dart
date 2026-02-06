import '../entities/word_entity.dart';

/// قرارداد انتزاعی برای دسترسی به داده‌های کلمه
/// 
/// رعایت اصول:
/// ۱. DIP: لایه‌های بالاتر فقط به این اینترفیس وابسته‌اند
/// ۲. ISP: متدها بر اساس مسئولیت‌های مجزا گروه‌بندی شده‌اند
/// ۳. OCP: می‌توان پیاده‌سازی‌های مختلف افزود بدون تغییر کد مصرف‌کننده
abstract class WordRepository {
  // ============================
  // عملیات CRUD پایه
  // ============================
  
  /// افزودن کلمه جدید
  /// 
  /// @param word: موجودیت کلمه برای افزودن
  /// @return شناسه یکتای کلمه ذخیره شده
  /// @throws WordRepositoryException در صورت خطا
  Future<int> addWord(WordEntity word);
  
  /// دریافت کلمه بر اساس شناسه
  Future<WordEntity?> getWordById(int id);
  
  /// به‌روزرسانی کلمه موجود
  Future<void> updateWord(WordEntity word);
  
  /// حذف کلمه بر اساس شناسه
  Future<void> deleteWord(int id);
  
  // ============================
  // عملیات بازیابی مجموعه‌ای
  // ============================
  
  /// دریافت تمام کلمات
  Future<List<WordEntity>> getAllWords();
  
  /// دریافت کلمات نیازمند مرور (بر اساس تاریخ)
  Future<List<WordEntity>> getWordsDueForReview();
  
  /// جستجوی کلمات بر اساس متن انگلیسی یا فارسی
  Future<List<WordEntity>> searchWords(String query);
  
  /// دریافت کلمات بر اساس سطح دشواری
  Future<List<WordEntity>> getWordsByDifficulty(int difficultyLevel);
  
  // ============================
  // عملیات ویژه SRS (سیستم مرور هوشمند)
  // ============================
  
  /// ثبت نتیجه یک مرور
  /// 
  /// @param wordId: شناسه کلمه
  /// @param answeredCorrectly: آیا کاربر به درستی پاسخ داده
  /// @return کلمه به‌روزشده پس از مرور
  Future<WordEntity> recordReview(int wordId, bool answeredCorrectly);
  
  /// دریافت تعداد کلمات نیازمند مرور امروز
  Future<int> getDueReviewCount();
  
  /// بازنشانی پیشرفت مرور برای کلمه خاص
  Future<void> resetReviewProgress(int wordId);
}

/// اینترفیس‌های جداگانه برای رعایت ISP در صورت نیاز
/// 
/// توجه: فعلاً از YAGNI پیروی می‌کنیم، اما ساختار برای تقسیم آماده است

/// فقط عملیات نوشتن
abstract class WordWriteRepository {
  Future<int> addWord(WordEntity word);
  Future<void> updateWord(WordEntity word);
  Future<void> deleteWord(int id);
  Future<WordEntity> recordReview(int wordId, bool answeredCorrectly);
}

/// فقط عملیات خواندن
abstract class WordReadRepository {
  Future<WordEntity?> getWordById(int id);
  Future<List<WordEntity>> getAllWords();
  Future<List<WordEntity>> getWordsDueForReview();
  Future<List<WordEntity>> searchWords(String query);
  Future<List<WordEntity>> getWordsByDifficulty(int difficultyLevel);
  Future<int> getDueReviewCount();
}

/// ============================
/// خطاهای اختصاصی ریپازیتوری
/// ============================

/// خطای پایه برای خطاهای ریپازیتوری
abstract class WordRepositoryException implements Exception {
  final String message;
  final dynamic innerError;
  
  const WordRepositoryException(this.message, [this.innerError]);
  
  @override
  String toString() => 'WordRepositoryException: $message${innerError != null ? ' (دلیل: $innerError)' : ''}';
}

/// خطای عدم یافتن کلمه
class WordNotFoundException extends WordRepositoryException {
  const WordNotFoundException(int wordId)
      : super('کلمه با شناسه $wordId یافت نشد.');
}

/// خطای تکراری بودن کلمه
class DuplicateWordException extends WordRepositoryException {
  const DuplicateWordException(String englishWord)
      : super('کلمه "$englishWord" از قبل وجود دارد.');
}

/// خطای داده نامعتبر
class InvalidWordDataException extends WordRepositoryException {
  const InvalidWordDataException(String fieldName)
      : super('داده کلمه در فیلد "$fieldName" معتبر نیست.');
}

/// خطای عملیات دیتابیس در ریپازیتوری
class WordDatabaseOperationException extends WordRepositoryException {
  const WordDatabaseOperationException(String operation, dynamic error)
      : super('خطا در عملیات $operation روی دیتابیس کلمات', error);
}
