// lib/features/word/data/models/word_model.dart

import 'dart:convert';

import 'package:english_learning_app/core/constants/app_constants.dart';

/// مدل داده یک کلمه/فلش‌کارت در لایه Data
/// با قابلیت تبدیل به/از JSON و Map برای دیتابیس
class WordModel {
  final int? id; // می‌تواند null باشد وقتی کلمه جدید است
  final String english;
  final String persian;
  final String? exampleSentence; // nullable - مثال اختیاری
  final int difficultyLevel; // 1=آسان, 2=متوسط, 3=سخت
  final DateTime nextReviewDate; // تاریخ مرور بعدی
  final int reviewInterval; // تعداد روز تا مرور بعدی
  final int correctReviews;
  final int wrongReviews;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WordModel({
    this.id,
    required this.english,
    required this.persian,
    this.exampleSentence,
    this.difficultyLevel = 1,
    required this.nextReviewDate,
    this.reviewInterval = 1,
    this.correctReviews = 0,
    this.wrongReviews = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 1. تبدیل به Map برای ذخیره در دیتابیس
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'persian': persian,
      'example_sentence': exampleSentence,
      'difficulty_level': difficultyLevel,
      'next_review_date': nextReviewDate.toIso8601String(),
      'review_interval': reviewInterval,
      'correct_reviews': correctReviews,
      'wrong_reviews': wrongReviews,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // 2. ساخت از Map (مثلاً وقتی از دیتابیس می‌خوانیم)
  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      english: map['english'] as String,
      persian: map['persian'] as String,
      exampleSentence: map['example_sentence'] as String?,
      difficultyLevel: map['difficulty_level'] as int,
      nextReviewDate: DateTime.parse(map['next_review_date'] as String),
      reviewInterval: map['review_interval'] as int,
      correctReviews: map['correct_reviews'] as int,
      wrongReviews: map['wrong_reviews'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }

  // 3. تبدیل به JSON (برای API یا ذخیره‌سازی)
  String toJson() => json.encode(toMap());
  
  // 4. ساخت از JSON
  factory WordModel.fromJson(String source) => 
      WordModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // 5. کپی کردن با امکان تغییر فیلدها (برای آپدیت‌های جزئی)
  WordModel copyWith({
    int? id,
    String? english,
    String? persian,
    String? exampleSentence,
    int? difficultyLevel,
    DateTime? nextReviewDate,
    int? reviewInterval,
    int? correctReviews,
    int? wrongReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      english: english ?? this.english,
      persian: persian ?? this.persian,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewInterval: reviewInterval ?? this.reviewInterval,
      correctReviews: correctReviews ?? this.correctReviews,
      wrongReviews: wrongReviews ?? this.wrongReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 6. منطق SRS: محاسبه تاریخ مرور بعدی بر اساس پاسخ کاربر
  WordModel calculateNextReview(bool wasCorrect) {
    final now = DateTime.now();
    int newInterval;
    DateTime newNextReviewDate;

    if (wasCorrect) {
      // اگر پاسخ صحیح بود، interval را افزایش بده
      newInterval = (reviewInterval * AppConstants.srsEasyFactor).ceil();
      newNextReviewDate = now.add(Duration(days: newInterval));
    } else {
      // اگر پاسخ غلط بود، interval را کاهش بده (اما حداقل 1 روز)
      newInterval = (reviewInterval * AppConstants.srsHardFactor).ceil();
      newInterval = newInterval.clamp(1, 365); // محدود کردن بین 1 تا 365 روز
      newNextReviewDate = now.add(Duration(days: newInterval));
    }

    return copyWith(
      reviewInterval: newInterval,
      nextReviewDate: newNextReviewDate,
      correctReviews: wasCorrect ? correctReviews + 1 : correctReviews,
      wrongReviews: wasCorrect ? wrongReviews : wrongReviews + 1,
      updatedAt: now,
    );
  }

  // 7. بررسی آیا کلمه برای امروز باید مرور شود؟
  bool get isDueForReview {
    return DateTime.now().isAfter(nextReviewDate) || 
           DateTime.now().isAtSameMomentAs(nextReviewDate);
  }

  @override
  String toString() {
    return 'WordModel(id: $id, english: $english, persian: $persian, nextReview: $nextReviewDate, interval: $reviewInterval days)';
  }

  // 8. مقایسه دو مدل برای برابری
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordModel &&
        other.id == id &&
        other.english == english;
  }

  @override
  int get hashCode {
    return id.hashCode ^ english.hashCode;
  }
}
