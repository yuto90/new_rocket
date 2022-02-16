import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mainpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面を縦に固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: Top(),
      home: MainPage(),
    );
  }
}
