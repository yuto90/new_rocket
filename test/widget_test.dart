import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('application shell renders the top screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{'clearLevel': 1});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [bannerAdsEnabledProvider.overrideWithValue(false)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlucky Rocket'), findsOneWidget);
    expect(find.text('遊び方'), findsOneWidget);
  });
}
