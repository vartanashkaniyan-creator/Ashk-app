import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'injection_container.dart';
import 'features/word/presentation/screens/add_word_screen.dart';

void main() async {
  // ۱. اطمینان از مقداردهی اولیه موتور Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // ۲. راه‌اندازی وابستگی‌ها (دیتابیس، ریپازیتوری‌ها و...)
  await setupDependencies();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ۳. نظارت بر وضعیت مقداردهی اولیه وابستگی‌ها
    final initialization = ref.watch(initializationProvider);
    
    return MaterialApp(
      title: 'English Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Vazir', // اگر فونت فارسی دارید
      ),
      debugShowCheckedModeBanner: false,
      home: initialization.when(
        data: (_) => const AddWordScreen(), // پس از آماده‌سازی، به صفحه اصلی برو
        loading: () => const SplashScreen(),
        error: (error, stack) => ErrorScreen(error: error.toString()),
      ),
    );
  }
}

/// صفحه اسپلش در حین بارگیری وابستگی‌ها
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال آماده‌سازی برنامه...'),
          ],
        ),
      ),
    );
  }
}

/// صفحه نمایش خطا
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'خطا در راه‌اندازی برنامه',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // می‌توانید برای تلاش مجدد، برنامه را ری‌استارت کنید
                },
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
