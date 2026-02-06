import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_learning_app/core/utils/database_helper.dart';
import 'package:english_learning_app/features/word/data/repositories/word_repository_impl.dart';
import 'package:english_learning_app/features/word/domain/repositories/word_repository.dart';

/// کانتینر اصلی تزریق وابستگی‌ها
/// 
/// رعایت اصول:
/// ۱. DIP: وابستگی‌ها به انتزاع‌ها ثبت می‌شوند
/// ۲. SRP: فقط مسئولیت ثبت و ارائه وابستگی‌ها
/// ۳. OCP: افزودن وابستگی جدید بدون تغییر کد موجود
class DependencyContainer {
  DependencyContainer._();
  
  static final DependencyContainer _instance = DependencyContainer._();
  
  factory DependencyContainer() => _instance;
  
  /// وابستگی‌های ثبت شده
  final Map<Type, Object> _dependencies = {};
  
  // ============================
  // ثبت وابستگی‌ها
  // ============================
  
  /// مقداردهی اولیه کانتینر
  Future<void> initialize() async {
    // ثبت DatabaseHelper
    final databaseHelper = DatabaseHelperImpl();
    await databaseHelper.initialize();
    _register<DatabaseHelper>(databaseHelper);
    
    // ثبت WordRepository
    final wordRepository = WordRepositoryImpl(databaseHelper);
    _register<WordRepository>(wordRepository);
    
    // سایر وابستگی‌ها در آینده اینجا ثبت می‌شوند
  }
  
  /// ثبت یک وابستگی
  void _register<T>(T dependency) {
    _dependencies[T] = dependency;
  }
  
  /// دریافت وابستگی
  T get<T>() {
    final dependency = _dependencies[T];
    
    if (dependency == null) {
      throw DependencyNotFoundException(T);
    }
    
    if (dependency is! T) {
      throw DependencyTypeMismatchException(T, dependency.runtimeType);
    }
    
    return dependency;
  }
  
  /// بررسی وجود وابستگی
  bool has<T>() => _dependencies.containsKey(T);
  
  /// حذف وابستگی (برای تست‌ها)
  void remove<T>() {
    _dependencies.remove(T);
  }
  
  /// ریست تمام وابستگی‌ها
  void reset() {
    _dependencies.clear();
  }
}

/// ============================
/// Providerهای Riverpod بر اساس DependencyContainer
/// ============================

/// Provider اصلی DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DependencyContainer().get<DatabaseHelper>();
});

/// Provider اصلی WordRepository
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return DependencyContainer().get<WordRepository>();
});

/// Provider برای بررسی وضعیت مقداردهی اولیه
final initializationProvider = FutureProvider<void>((ref) async {
  final container = DependencyContainer();
  
  if (!container.has<DatabaseHelper>()) {
    await container.initialize();
  }
  
  // در اینجا می‌توانید سایر عملیات اولیه‌سازی را انجام دهید
  // مثلاً بارگیری تنظیمات کاربر، کش اولیه و...
});

/// ============================
/// خطاهای تزریق وابستگی
/// ============================

/// خطای پایه برای Dependency Injection
abstract class DependencyInjectionException implements Exception {
  final String message;
  
  const DependencyInjectionException(this.message);
  
  @override
  String toString() => 'DependencyInjectionException: $message';
}

/// خطای عدم یافتن وابستگی
class DependencyNotFoundException extends DependencyInjectionException {
  DependencyNotFoundException(Type type)
      : super('وابستگی نوع $type یافت نشد. '
              'مطمئن شوید ابتدا متد initialize() را فراخوانی کرده‌اید.');
}

/// خطای عدم تطابق نوع
class DependencyTypeMismatchException extends DependencyInjectionException {
  DependencyTypeMismatchException(Type expected, Type actual)
      : super('نوع وابستگی تطابق ندارد. '
              'انتظار می‌رفت: $expected، اما دریافت شد: $actual');
}

/// ============================
/// توابع کمکی برای دسترسی آسان‌تر
/// ============================

/// دریافت وابستگی از کانتینر (برای جاهایی که Ref در دسترس نیست)
T getDependency<T>() {
  return DependencyContainer().get<T>();
}

/// مقداردهی اولیه کانتینر (در main.dart فراخوانی شود)
Future<void> setupDependencies() async {
  await DependencyContainer().initialize();
}
