// lib/core/utils/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  // Singleton pattern برای داشتن تنها یک instance از دیتابیس
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      // onUpgrade برای نسخه‌های بعدی قابل اضافه شدن است
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول کلمات (هسته اصلی اپ)
    await db.execute('''
      CREATE TABLE ${AppConstants.wordsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        persian TEXT NOT NULL,
        example_sentence TEXT,
        difficulty_level INTEGER DEFAULT 1,
        next_review_date TEXT, -- ذخیره به صورت رشته ISO 8601
        review_interval INTEGER DEFAULT 1, -- تعداد روز تا مرور بعدی
        correct_reviews INTEGER DEFAULT 0,
        wrong_reviews INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // ایجاد ایندکس برای جستجوی سریع‌تر
    await db.execute('''
      CREATE INDEX idx_english 
      ON ${AppConstants.wordsTable} (english)
    ''');

    // برای آینده: جدول کاربران
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        daily_goal INTEGER DEFAULT ${AppConstants.maxWordsPerDay},
        created_at TEXT NOT NULL
      )
    ''');
    
    print('✅ Database and tables created successfully');
  }

  // -------------------- متدهای کمکی عمومی --------------------
  
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    // اضافه کردن timestamp به داده‌ها
    final now = DateTime.now().toIso8601String();
    data['created_at'] = now;
    data['updated_at'] = now;
    
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // بستن اتصال دیتابیس (برای تست‌ها یا زمان خروج از اپ)
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
