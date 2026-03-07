import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_placement.dart';
import '../app_ads.dart';
import '../ads_controller.dart';

class CommunityNativeAdSlot extends StatefulWidget {
  const CommunityNativeAdSlot({super.key, required this.slotIndex});

  final int slotIndex;

  @override
  State<CommunityNativeAdSlot> createState() => _CommunityNativeAdSlotState();
}

class _CommunityNativeAdSlotState extends State<CommunityNativeAdSlot> {
  static const double _slotHeight = 184;

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _hasFailed = false;
  bool? _loadedNonPersonalizedAds;
  bool _loadScheduled = false;

  @override
  void dispose() {
    final nativeAd = _nativeAd;
    _nativeAd = null;
    if (nativeAd != null) {
      unawaited(nativeAd.dispose());
    }
    super.dispose();
  }

  void _scheduleLoadIfNeeded(AdsRuntimeState runtimeState) {
    if (_hasFailed || _isLoading || _loadScheduled) {
      return;
    }

    final alreadyLoaded =
        _nativeAd != null &&
        _isLoaded &&
        _loadedNonPersonalizedAds == runtimeState.nonPersonalizedAds;
    if (alreadyLoaded) {
      return;
    }

    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (!mounted) {
        return;
      }
      unawaited(_loadAd(runtimeState));
    });
  }

  Future<void> _loadAd(AdsRuntimeState runtimeState) async {
    if (_hasFailed || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoaded = false;
    });

    final previousAd = _nativeAd;
    _nativeAd = null;
    if (previousAd != null) {
      unawaited(previousAd.dispose());
    }

    try {
      final nativeAd = NativeAd(
        adUnitId: appAdsConfig().adUnitIdFor(AdPlacement.communityNative),
        factoryId: 'communityFeedNative',
        request: runtimeState.canLoadAds
            ? appAdsController().createAdRequest()
            : const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              unawaited(ad.dispose());
              return;
            }

            setState(() {
              _nativeAd = ad as NativeAd;
              _isLoaded = true;
              _isLoading = false;
              _loadedNonPersonalizedAds = runtimeState.nonPersonalizedAds;
            });
          },
          onAdFailedToLoad: (ad, error) {
            unawaited(ad.dispose());
            if (!mounted) {
              return;
            }

            setState(() {
              _nativeAd = null;
              _isLoaded = false;
              _isLoading = false;
              _hasFailed = true;
            });
          },
        ),
        customOptions: {'slotIndex': widget.slotIndex},
      );

      await nativeAd.load();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _nativeAd = null;
        _isLoaded = false;
        _isLoading = false;
        _hasFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AdsRuntimeState>(
      valueListenable: appAdsController(),
      builder: (context, runtimeState, _) {
        if (!runtimeState.canLoadAds) {
          return const SizedBox.shrink();
        }

        _scheduleLoadIfNeeded(runtimeState);

        final nativeAd = _nativeAd;
        if (!_isLoaded || nativeAd == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: _slotHeight,
            child: AdWidget(ad: nativeAd),
          ),
        );
      },
    );
  }
}
