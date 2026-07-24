import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/ads/banner_ad_gateway.dart';
import 'package:new_rocket/ads/banner_ad_state.dart';

class FakeBannerAdResource implements BannerAdResource {
  int disposeCount = 0;

  @override
  Widget buildWidget() => const SizedBox();

  @override
  void dispose() {
    disposeCount += 1;
  }
}

class FakeBannerAdGateway implements BannerAdGateway {
  FakeBannerAdGateway.success() : _automaticError = null, _isPending = false;

  FakeBannerAdGateway.failure(Object error)
    : _automaticError = error,
      _isPending = false;

  FakeBannerAdGateway.pending() : _automaticError = null, _isPending = true;

  final FakeBannerAdResource resource = FakeBannerAdResource();
  final Completer<BannerAdResource> _result = Completer<BannerAdResource>();
  final Completer<void> _completed = Completer<void>();
  final Object? _automaticError;
  final bool _isPending;
  final List<String> requestedAdUnitIds = [];
  int loadCount = 0;

  Future<void> get completed => _completed.future;

  @override
  Future<BannerAdResource> initializeAndLoad(String adUnitId) {
    loadCount += 1;
    requestedAdUnitIds.add(adUnitId);

    if (!_isPending) {
      scheduleMicrotask(() {
        final error = _automaticError;
        if (error == null) {
          succeed();
        } else {
          fail(error);
        }
      });
    }

    return _result.future;
  }

  void succeed() {
    if (!_result.isCompleted) {
      _result.complete(resource);
    }
    if (!_completed.isCompleted) {
      _completed.complete();
    }
  }

  void fail(Object error) {
    if (!_result.isCompleted) {
      _result.completeError(error);
    }
    if (!_completed.isCompleted) {
      _completed.complete();
    }
  }
}

void main() {
  test('loads one banner for the app session', () async {
    final gateway = FakeBannerAdGateway.success();
    final container = ProviderContainer(
      overrides: [
        bannerAdGatewayProvider.overrideWithValue(gateway),
        bannerAdsEnabledProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    container.read(bannerAdProvider);
    container.read(bannerAdProvider);
    await gateway.completed;

    final state = container.read(bannerAdProvider);
    expect(state.phase, BannerAdPhase.loaded);
    expect(state.resource, same(gateway.resource));
    expect(gateway.loadCount, 1);
    expect(gateway.requestedAdUnitIds, [
      'ca-app-pub-3940256099942544/6300978111',
    ]);
  });

  test('disposing the container disposes a loaded banner', () async {
    final gateway = FakeBannerAdGateway.success();
    final container = ProviderContainer(
      overrides: [
        bannerAdGatewayProvider.overrideWithValue(gateway),
        bannerAdsEnabledProvider.overrideWithValue(true),
      ],
    );
    container.read(bannerAdProvider);
    await gateway.completed;

    container.dispose();

    expect(gateway.resource.disposeCount, 1);
  });

  test('disabled ads do not initialize or load a banner', () {
    final gateway = FakeBannerAdGateway.success();
    final container = ProviderContainer(
      overrides: [
        bannerAdGatewayProvider.overrideWithValue(gateway),
        bannerAdsEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(bannerAdProvider);

    expect(state.phase, BannerAdPhase.disabled);
    expect(state.resource, isNull);
    expect(gateway.loadCount, 0);
  });

  test('a load failure is hidden and is not retried', () async {
    final gateway = FakeBannerAdGateway.failure(
      StateError('Mobile Ads unavailable'),
    );
    final container = ProviderContainer(
      overrides: [
        bannerAdGatewayProvider.overrideWithValue(gateway),
        bannerAdsEnabledProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    container.read(bannerAdProvider);
    await gateway.completed;
    container.read(bannerAdProvider);

    final state = container.read(bannerAdProvider);
    expect(state.phase, BannerAdPhase.failed);
    expect(state.resource, isNull);
    expect(gateway.loadCount, 1);
  });

  test(
    'a late load completion is disposed without updating provider state',
    () async {
      final gateway = FakeBannerAdGateway.pending();
      final phases = <BannerAdPhase>[];
      final container = ProviderContainer(
        overrides: [
          bannerAdGatewayProvider.overrideWithValue(gateway),
          bannerAdsEnabledProvider.overrideWithValue(true),
        ],
      );
      container.listen(
        bannerAdProvider,
        (_, next) => phases.add(next.phase),
        fireImmediately: true,
      );

      container.dispose();
      gateway.succeed();
      await gateway.completed;

      expect(gateway.resource.disposeCount, 1);
      expect(phases, [BannerAdPhase.loading]);
    },
  );
}
