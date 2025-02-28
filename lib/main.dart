import 'package:flutter/material.dart';
import 'screens/schedule_screen.dart'; // 追加
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  // asyncを追加
  // プラグインを使用する前にFlutterバインディングを確実に初期化
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // バナーを非表示にする
      title: 'スケジューラー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScheduleScreen(), // MyHomePageからScheduleScreenに変更
    );
  }
}
