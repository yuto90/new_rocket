import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_rocket/mainpage_model.dart';
import 'package:provider/provider.dart';
import 'mainpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await MobileAds.instance.initialize();
  } catch (error) {
    debugPrint('Mobile Ads initialization failed: $error');
  }
  // 画面を縦に固定
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        // アプリ全体にフォントを適用
        textTheme: GoogleFonts.dotGothic16TextTheme(),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MainPageModel>(
            create: (context) => MainPageModel(),
          ),
        ],
        child: MainPage(),
      ),
    );
  }
}
