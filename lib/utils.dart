// lib/utils.dart

// ============================================
// VALIDATION UTILS (قابل تست بودن)
// ============================================

/// SRP: فقط اعتبارسنجی رشته‌های غیرخالی
class ValidationUtils {
  /// بررسی می‌کند رشته خالی نباشد و فقط حروف داشته باشد
  static bool isValidWord(String? word) {
    if (word == null || word.trim().isEmpty) return false;
    // فقط حروف انگلیسی و فاصله مجاز
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(word.trim());
  }

  /// بررسی می‌کند رشته معنی فارسی معتبر باشد
  static bool isValidPersian(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    // حروف فارسی، عربی، فاصله و اعداد
    return RegExp(r'^[\u0600-\u06FF\s0-9]+$').hasMatch(text.trim());
  }

  /// بررسی کیفیت ورودی SRS (بین 0 تا 5)
  static bool isValidQuality(int quality) {
    return quality >= 0 && quality <= 5;
  }

  /// اعتبارسنجی ایمیل (برای آینده)
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }
}

// ============================================
// DATE & TIME UTILS (DRY: جلوگیری از تکرار)
// ============================================

/// SRP: فقط کار با تاریخ و زمان
class DateUtils {
  /// فرمت تاریخ برای نمایش در UI
  static String formatDate(DateTime date, {bool withTime = false}) {
    final persianMonth = _getPersianMonth(date.month);
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    if (!withTime) {
      return '$day $persianMonth $year';
    }
    
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $persianMonth $year - $hour:$minute';
  }

  /// تبدیل ماه میلادی به نام فارسی
  static String _getPersianMonth(int month) {
    const months = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return months[month - 1];
  }

  /// محاسبه تاریخ مرور بعدی بر اساس الگوریتم SRS
  static DateTime calculateNextReview(DateTime now, int intervalDays) {
    return now.add(Duration(days: intervalDays));
  }

  /// بررسی آیا تاریخ گذشته است یا نه
  static bool isDatePast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// اختلاف دو تاریخ به صورت متن خوانا
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years سال پیش';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقیقه پیش';
    } else {
      return 'همین الان';
    }
  }
}

// ============================================
// STRING UTILS (KISS: ساده و کاربردی)
// ============================================

/// SRP: عملیات روی رشته‌ها
class StringUtils {
  /// کوتاه کردن متن با اضافه کردن سه نقطه
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// حذف فاصله‌های اضافی
  static String normalizeSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// تبدیل به حالت عنوان (اول هر کلمه بزرگ)
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// شمارش کلمات
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}

// ============================================
// UI UTILS (برای Presentation Layer)
// ============================================

/// SRP: توابع کمکی برای UI
class UiUtils {
  /// تولید رنگ بر اساس وضعیت مرور
  static Color getReviewStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.upToDate:
        return Colors.green;
      case ReviewStatus.dueSoon:
        return Colors.orange;
      case ReviewStatus.overdue:
        return Colors.red;
    }
  }

  /// گرفتن آیکون مناسب برای وضعیت مرور
  static IconData getReviewStatusIcon(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.upToDate:
        return Icons.check_circle;
      case ReviewStatus.dueSoon:
        return Icons.access_time;
      case ReviewStatus.overdue:
        return Icons.warning;
    }
  }

  /// نمایش SnackBar با پیام
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// نمایش دیالوگ تایید
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تایید'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ============================================
// MATH UTILS (برای محاسبات SRS)
// ============================================

/// SRP: محاسبات ریاضی مربوط به الگوریتم SRS
class MathUtils {
  /// محاسبه فاصله مرور جدید طبق الگوریتم SM-2
  static int calculateSrsInterval(int currentInterval, double easeFactor, int quality) {
    if (quality < 3) return 1; // بازگشت به شروع
    
    final newInterval = (currentInterval * easeFactor).round();
    return newInterval.clamp(1, 365); // محدود کردن به ۱ تا ۳۶۵ روز
  }

  /// محاسبه ضریب آسانی جدید
  static double calculateSrsEaseFactor(double currentEase, int quality) {
    double newEase = currentEase +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    
    return newEase.clamp(1.3, 2.5);
  }

  /// پیش‌بینی تعداد کلمات برای مرور در آینده
  static Map<DateTime, int> predictFutureReviews(List<Word> words) {
    final now = DateTime.now();
    final Map<DateTime, int> predictions = {};
    
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final count = words.where((word) {
        return word.nextReview.year == date.year &&
               word.nextReview.month == date.month &&
               word.nextReview.day == date.day;
      }).length;
      
      if (count > 0) {
        predictions[date] = count;
      }
    }
    
    return predictions;
  }
}

// ============================================
// EXTENSIONS (برای بهبود خوانایی)
// ============================================

/// OCP: اضافه کردن قابلیت‌های جدید به کلاس‌های موجود
extension DateTimeExtension on DateTime {
  /// آیا تاریخ امروز است؟
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// آیا تاریخ فرداست؟
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// فرمت تاریخ به صورت متن خوانا
  String get toPersianString => DateUtils.formatDate(this);
}

extension StringExtension on String {
  /// آیا رشته معنی فارسی معتبر است؟
  bool get isValidPersian => ValidationUtils.isValidPersian(this);

  /// آیا رشته کلمه انگلیسی معتبر است؟
  bool get isValidEnglishWord => ValidationUtils.isValidWord(this);

  /// کوتاه کردن متن
  String truncate({int maxLength = 30}) => StringUtils.truncate(this, maxLength: maxLength);
}

extension ListWordExtension on List<Word> {
  /// گرفتن کلمات نیازمند مرور
  List<Word> get dueForReview {
    final now = DateTime.now();
    return where((word) => word.nextReview.isBefore(now)).toList();
  }

  /// گرفتن آمار مرور
  Map<ReviewStatus, int> get reviewStats {
    int upToDate = 0;
    int dueSoon = 0;
    int overdue = 0;
    
    for (final word in this) {
      switch (word.reviewStatus) {
        case ReviewStatus.upToDate:
          upToDate++;
          break;
        case ReviewStatus.dueSoon:
          dueSoon++;
          break;
        case ReviewStatus.overdue:
          overdue++;
          break;
      }
    }
    
    return {
      ReviewStatus.upToDate: upToDate,
      ReviewStatus.dueSoon: dueSoon,
      ReviewStatus.overdue: overdue,
    };
  }
}
