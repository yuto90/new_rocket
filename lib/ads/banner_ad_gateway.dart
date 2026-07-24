import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract interface class BannerAdResource {
  Widget buildWidget();
  void dispose();
}

abstract interface class BannerAdGateway {
  Future<BannerAdResource> initializeAndLoad(String adUnitId);
}

class GoogleMobileAdsBannerAdGateway implements BannerAdGateway {
  @override
  Future<BannerAdResource> initializeAndLoad(String adUnitId) async {
    await MobileAds.instance.initialize();

    final completer = Completer<BannerAdResource>();
    late final BannerAd banner;
    banner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!completer.isCompleted) {
            completer.complete(GoogleMobileAdsBannerResource(banner));
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      ),
    );
    unawaited(banner.load());

    return completer.future;
  }
}

class GoogleMobileAdsBannerResource implements BannerAdResource {
  GoogleMobileAdsBannerResource(this._banner);

  final BannerAd _banner;

  @override
  Widget buildWidget() => AdWidget(ad: _banner);

  @override
  void dispose() {
    _banner.dispose();
  }
}
