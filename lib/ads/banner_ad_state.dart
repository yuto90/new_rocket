import 'package:new_rocket/ads/banner_ad_gateway.dart';

enum BannerAdPhase { initial, loading, loaded, failed, disabled }

class BannerAdState {
  const BannerAdState._({required this.phase, this.resource});

  const BannerAdState.initial() : this._(phase: BannerAdPhase.initial);

  const BannerAdState.loading() : this._(phase: BannerAdPhase.loading);

  const BannerAdState.loaded(BannerAdResource resource)
    : this._(phase: BannerAdPhase.loaded, resource: resource);

  const BannerAdState.failed() : this._(phase: BannerAdPhase.failed);

  const BannerAdState.disabled() : this._(phase: BannerAdPhase.disabled);

  final BannerAdPhase phase;
  final BannerAdResource? resource;
}
