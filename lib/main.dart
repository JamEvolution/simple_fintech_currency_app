import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/logger_utils.dart';
import 'core/errors/error_handler.dart';
import 'features/currency_converter/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uygulamayı başlatmadan önce logger'ı yapılandır
  AppLogger.info('Uygulama başlatılıyor');
  
  // Hata yakalama servisini başlat
  await ErrorHandler.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.d('Ana uygulama oluşturuluyor');
    return MaterialApp(
      title: 'Döviz Dönüştürücü',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
