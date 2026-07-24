import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/ads/banner_ad_state.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/size_config.dart';

class BannerAdView extends ConsumerWidget {
  const BannerAdView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameMode = ref.watch(
      gameControllerProvider.select((game) => game.mode),
    );
    final bannerState = ref.watch(bannerAdProvider);
    final hideBanner =
        gameMode == GameMode.clear ||
        gameMode == GameMode.ready ||
        gameMode == GameMode.playing;

    if (hideBanner ||
        bannerState.phase != BannerAdPhase.loaded ||
        bannerState.resource == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: SizeConfig.blockSizeVertical! * 8,
        width: double.infinity,
        child: bannerState.resource!.buildWidget(),
      ),
    );
  }
}
