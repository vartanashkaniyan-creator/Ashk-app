// lib/features/word/domain/repositories/word_repository.dart

import '../entities/word_entity.dart';

/// قرارداد (اینترفیس) ریپازیتوری کلمات در لایه Domain
/// تمام عملیات مورد نیاز روی داده‌های کلمه را تعریف می‌کند
/// این یک abstract class است و پیاده‌سازی واقعی در لایه Data خواهد بود
abstract class WordRepository {
  // ------------ عملیات CRUD پایه ------------
  /// افزودن کلمه جدید
  Future<int> addWord(WordEntity word);
  
  /// دریافت کلمه بر اساس ID
  Future<WordEntity?> getWordById(int id);
  
  /// دریافت تمام کلمات
  Future<List<WordEntity>> getAllWords();
  
  /// به‌روزرسانی کلمه موجود
  Future<bool> updateWord(WordEntity word);
  
  /// حذف کلمه
  Future<bool> deleteWord(int id);
  
  // ------------ عملیات خاص سیستم SRS ------------
  /// دریافت کلمات نیازمند مرور در تاریخ مشخص
  /// [limit] محدودیت تعداد کلمات دریافتی
  Future<List<WordEntity>> getWordsDueForReview({
    DateTime? date,
    int limit = 20,
  });
  
  /// ثبت نتیجه مرور یک کلمه و محاسبه مرور بعدی
  /// [wordId] شناسه کلمه
  /// [wasCorrect] آیا کاربر پاسخ صحیح داد؟
  Future<bool> recordReviewResult({
    required int wordId,
    required bool wasCorrect,
  });
  
  /// دریافت کلمات بر اساس سطح دشواری
  Future<List<WordEntity>> getWordsByDifficulty(int difficultyLevel);
  
  /// جستجوی کلمات (انگلیسی یا فارسی)
  Future<List<WordEntity>> searchWords(String query);
  
  /// دریافت آمار کلی
  Future<WordStats> getWordStats();
  
  // ------------ عملیات گروهی ------------
  /// افزودن چند کلمه یکجا
  Future<List<int>> addWords(List<WordEntity> words);
  
  /// به‌روزرسانی وضعیت مرور چند کلمه
  Future<bool> bulkUpdateReviewStatus(List<WordEntity> words);
  
  // ------------ عملیات پیشرفته (برای آینده) ------------
  /// وارد کردن کلمات از فایل
  Future<int> importFromJson(String jsonData);
  
  /// صادر کردن کلمات به فایل
  Future<String> exportToJson();
  
  /// همگام‌سازی با سرور (برای نسخه‌های بعدی)
  Future<bool> syncWithCloud();
}

/// مدل آماری برای گزارش‌گیری
class WordStats {
  final int totalWords;
  final int wordsDueForReview;
  final int wordsReviewedToday;
  final double averageMastery;
  final Map<int, int> wordsByDifficulty; // تعداد کلمات در هر سطح
  
  WordStats({
    required this.totalWords,
    required this.wordsDueForReview,
    required this.wordsReviewedToday,
    required this.averageMastery,
    required this.wordsByDifficulty,
  });
  
  // فکتوری برای حالت خالی
  factory WordStats.empty() {
    return WordStats(
      totalWords: 0,
      wordsDueForReview: 0,
      wordsReviewedToday: 0,
      averageMastery: 0.0,
      wordsByDifficulty: {1: 0, 2: 0, 3: 0},
    );
  }
  
  @override
  String toString() {
    return 'WordStats(total: $totalWords, due: $wordsDueForReview, reviewedToday: $wordsReviewedToday, mastery: ${averageMastery.toStringAsFixed(1)}%)';
  }
}

/// خطاهای خاص ریپازیتوری کلمات
abstract class WordRepositoryError {
  static const String wordNotFound = 'WORD_NOT_FOUND';
  static const String duplicateWord = 'DUPLICATE_WORD';
  static const String invalidData = 'INVALID_WORD_DATA';
  static const String databaseError = 'DATABASE_ERROR';
}
