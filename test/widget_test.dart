import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/mainpage.dart';
import 'package:new_rocket/mainpage_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('保存済みのクリアレベルを読み込む', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'clearLevel': 3});
    final model = MainPageModel(loadAds: false);
    addTearDown(model.dispose);

    expect(await model.getClearLevel(), 3);
    expect(model.isClear(2), isTrue);
    expect(model.isClear(3), isFalse);
  });

  test('ゲーム位置を初期状態へ戻す', () {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final model = MainPageModel(loadAds: false)
      ..rocketYaxis = -0.5
      ..gameHasStarted = true
      ..count = 1000
      ..goal = 0
      ..city = 2;
    addTearDown(model.dispose);

    model.resetPosition();

    expect(model.rocketYaxis, 0);
    expect(model.gameHasStarted, isFalse);
    expect(model.count, 0);
    expect(model.goal, -3);
    expect(model.city, 1.1);
  });

  test('レベル選択で難易度を更新する', () {
    final model = MainPageModel(loadAds: false);
    addTearDown(model.dispose);

    model.switchLevel(3);

    expect(model.selectedLevel, 3);
    expect(model.level, 5.0);
  });

  testWidgets('トップ画面からレベル1の開始画面へ遷移する', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{'clearLevel': 1});
    final model = MainPageModel(loadAds: false);
    addTearDown(model.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<MainPageModel>.value(
          value: model,
          child: MainPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlucky Rocket'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pump();

    expect(find.text('L E V E L 1'), findsOneWidget);
    expect(find.text('画面をタップしたらスタートするよ'), findsOneWidget);
  });
}
