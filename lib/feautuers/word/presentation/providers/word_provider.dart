import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_learning_app/features/word/domain/entities/word_entity.dart';
import 'package:english_learning_app/features/word/domain/usecases/add_word_usecase.dart';
import 'package:english_learning_app/features/word/domain/repositories/word_repository.dart';

// ============================
// Providerهای اصلی (Singletons)
// ============================

/// Provider اصلی WordRepository
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  // در آینده از injection_container تزریق می‌شود
  throw UnimplementedError('ابتدا باید DatabaseHelperProvider تعریف شود');
});

/// Provider برای AddWordUseCase
final addWordUseCaseProvider = Provider<AddWordUseCase>((ref) {
  final repository = ref.watch(wordRepositoryProvider);
  return AddWordUseCase(repository);
});

// ============================
// State Providers برای مدیریت حالت
// ============================

/// وضعیت فرم افزودن کلمه
class AddWordFormState {
  final String english;
  final String persian;
  final String exampleSentence;
  final int difficultyLevel;
  final bool isSubmitting;
  final String? error;
  final int? lastAddedWordId;

  const AddWordFormState({
    this.english = '',
    this.persian = '',
    this.exampleSentence = '',
    this.difficultyLevel = 1,
    this.isSubmitting = false,
    this.error,
    this.lastAddedWordId,
  });

  /// آیا فرم قابل ارسال است؟
  bool get isValid => 
      english.trim().isNotEmpty && 
      persian.trim().isNotEmpty &&
      !isSubmitting;

  /// ایجاد کپی با تغییرات
  AddWordFormState copyWith({
    String? english,
    String? persian,
    String? exampleSentence,
    int? difficultyLevel,
    bool? isSubmitting,
    String? error,
    int? lastAddedWordId,
  }) {
    return AddWordFormState(
      english: english ?? this.english,
      persian: persian ?? this.persian,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      lastAddedWordId: lastAddedWordId ?? this.lastAddedWordId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddWordFormState &&
        other.english == english &&
        other.persian == persian &&
        other.exampleSentence == exampleSentence &&
        other.difficultyLevel == difficultyLevel &&
        other.isSubmitting == isSubmitting &&
        other.error == error &&
        other.lastAddedWordId == lastAddedWordId;
  }

  @override
  int get hashCode {
    return Object.hash(
      english,
      persian,
      exampleSentence,
      difficultyLevel,
      isSubmitting,
      error,
      lastAddedWordId,
    );
  }
}

/// StateNotifier برای مدیریت حالت فرم افزودن کلمه
class AddWordFormNotifier extends StateNotifier<AddWordFormState> {
  AddWordFormNotifier() : super(const AddWordFormState());

  /// به‌روزرسانی متن انگلیسی
  void updateEnglish(String value) {
    state = state.copyWith(english: value, error: null);
  }

  /// به‌روزرسانی متن فارسی
  void updatePersian(String value) {
    state = state.copyWith(persian: value, error: null);
  }

  /// به‌روزرسانی مثال
  void updateExampleSentence(String value) {
    state = state.copyWith(exampleSentence: value, error: null);
  }

  /// به‌روزرسانی سطح دشواری
  void updateDifficultyLevel(int level) {
    state = state.copyWith(difficultyLevel: level, error: null);
  }

  /// ارسال فرم
  Future<void> submit(WidgetRef ref) async {
    if (!state.isValid) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final useCase = ref.read(addWordUseCaseProvider);
      final wordId = await useCase.execute(
        english: state.english,
        persian: state.persian,
        exampleSentence: state.exampleSentence.isEmpty 
            ? null 
            : state.exampleSentence,
        difficultyLevel: state.difficultyLevel,
      );

      state = state.copyWith(
        isSubmitting: false,
        lastAddedWordId: wordId,
        english: '',
        persian: '',
        exampleSentence: '',
        difficultyLevel: 1,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        error: error.toString(),
      );
    }
  }

  /// ریست کردن فرم
  void reset() {
    state = const AddWordFormState();
  }
}

/// StateNotifierProvider برای فرم افزودن کلمه
final addWordFormProvider = 
    StateNotifierProvider<AddWordFormNotifier, AddWordFormState>(
  (ref) => AddWordFormNotifier(),
);

// ============================
// Providers برای لیست کلمات
// ============================

/// حالت لیست کلمات
class WordListState {
  final List<WordEntity> words;
  final bool isLoading;
  final String? error;

  const WordListState({
    this.words = const [],
    this.isLoading = false,
    this.error,
  });

  WordListState copyWith({
    List<WordEntity>? words,
    bool? isLoading,
    String? error,
  }) {
    return WordListState(
      words: words ?? this.words,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier برای مدیریت لیست کلمات
class WordListNotifier extends StateNotifier<WordListState> {
  WordListNotifier(this.ref) : super(const WordListState()) {
    _loadWords();
  }

  final Ref ref;

  /// بارگیری کلمات
  Future<void> _loadWords() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(wordRepositoryProvider);
      final words = await repository.getAllWords();
      state = state.copyWith(words: words, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        error: 'خطا در بارگیری کلمات: $error',
        isLoading: false,
      );
    }
  }

  /// رفرش لیست
  Future<void> refresh() async {
    await _loadWords();
  }

  /// افزودن کلمه به لیست (بدون نیاز به رفرش کامل)
  void addWordToList(WordEntity word) {
    final newWords = [word, ...state.words];
    state = state.copyWith(words: newWords);
  }

  /// حذف کلمه از لیست
  Future<void> removeWord(int wordId) async {
    try {
      final repository = ref.read(wordRepositoryProvider);
      await repository.deleteWord(wordId);
      
      final newWords = state.words.where((w) {
        if (w is WordEntity) {
          // اگر WordEntity دارای id باشد
          return true; // در آینده پیاده‌سازی می‌شود
        }
        return true;
      }).toList();
      
      state = state.copyWith(words: newWords);
    } catch (error) {
      state = state.copyWith(error: 'خطا در حذف کلمه: $error');
    }
  }
}

/// StateNotifierProvider برای لیست کلمات
final wordListProvider = StateNotifierProvider<WordListNotifier, WordListState>(
  (ref) => WordListNotifier(ref),
);

// ============================
// Providerهای کمکی (Computed)
// ============================

/// تعداد کلمات موجود
final wordCountProvider = Provider<int>((ref) {
  final state = ref.watch(wordListProvider);
  return state.words.length;
});

/// تعداد کلمات نیازمند مرور
final dueReviewCountProvider = FutureProvider<int>((ref) async {
  try {
    final repository = ref.read(wordRepositoryProvider);
    return await repository.getDueReviewCount();
  } catch (error) {
    return 0;
  }
});

/// فیلتر کلمات بر اساس سطح دشواری
final wordsByDifficultyProvider = Provider.family<List<WordEntity>, int>(
  (ref, difficultyLevel) {
    final state = ref.watch(wordListProvider);
    return state.words
        .where((word) => word.difficultyLevel == difficultyLevel)
        .toList();
  },
);

/// جستجوی کلمات
final searchWordsProvider = Provider.family<List<WordEntity>, String>(
  (ref, query) {
    if (query.isEmpty) return [];
    
    final state = ref.watch(wordListProvider);
    return state.words
        .where((word) =>
            word.english.toLowerCase().contains(query.toLowerCase()) ||
            word.persian.toLowerCase().contains(query.toLowerCase()))
        .toList();
  },
);
