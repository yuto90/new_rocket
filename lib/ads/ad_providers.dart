import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/ads/banner_ad_controller.dart';
import 'package:new_rocket/ads/banner_ad_gateway.dart';
import 'package:new_rocket/ads/banner_ad_state.dart';

final bannerAdGatewayProvider = Provider<BannerAdGateway>(
  (ref) => GoogleMobileAdsBannerAdGateway(),
);

final bannerAdsEnabledProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);

final bannerAdProvider = NotifierProvider<BannerAdController, BannerAdState>(
  BannerAdController.new,
);
