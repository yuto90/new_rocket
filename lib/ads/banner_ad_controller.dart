import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/ads/banner_ad_gateway.dart';
import 'package:new_rocket/ads/banner_ad_state.dart';

const androidTestAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const iosTestAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

class BannerAdController extends Notifier<BannerAdState> {
  BannerAdResource? _resource;
  bool _disposed = false;

  @override
  BannerAdState build() {
    ref.onDispose(_disposeResources);

    if (!ref.read(bannerAdsEnabledProvider)) {
      return const BannerAdState.disabled();
    }

    unawaited(_load());
    return const BannerAdState.loading();
  }

  Future<void> _load() async {
    try {
      final gateway = ref.read(bannerAdGatewayProvider);
      final resource = await gateway.initializeAndLoad(_adUnitId());
      if (_disposed) {
        resource.dispose();
        return;
      }

      _resource = resource;
      state = BannerAdState.loaded(resource);
    } catch (_) {
      if (!_disposed) {
        state = const BannerAdState.failed();
      }
    }
  }

  String _adUnitId() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        kDebugMode
            ? androidTestAdUnitId
            : dotenv.env['BANNER_UNIT_ID_ANDROID']!,
      TargetPlatform.iOS =>
        kDebugMode ? iosTestAdUnitId : dotenv.env['BANNER_UNIT_ID_IOS']!,
      _ => '',
    };
  }

  void _disposeResources() {
    _disposed = true;
    _resource?.dispose();
    _resource = null;
  }
}
