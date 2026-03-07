import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_placement.dart';
import '../app_ads.dart';
import '../ads_controller.dart';

class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key, required this.placement});

  final AdPlacement placement;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _hasFailed = false;
  int? _loadedWidth;
  bool? _loadedNonPersonalizedAds;
  String? _scheduledLoadSignature;

  @override
  void dispose() {
    final bannerAd = _bannerAd;
    _bannerAd = null;
    if (bannerAd != null) {
      unawaited(bannerAd.dispose());
    }
    super.dispose();
  }

  void _scheduleLoadIfNeeded({
    required int width,
    required AdsRuntimeState runtimeState,
  }) {
    if (_hasFailed || _isLoading || width <= 0) {
      return;
    }

    final alreadyLoaded =
        _bannerAd != null &&
        _isLoaded &&
        _loadedWidth == width &&
        _loadedNonPersonalizedAds == runtimeState.nonPersonalizedAds;
    if (alreadyLoaded) {
      return;
    }

    final signature = '$width:${runtimeState.nonPersonalizedAds}';
    if (_scheduledLoadSignature == signature) {
      return;
    }

    _scheduledLoadSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledLoadSignature = null;
      if (!mounted) {
        return;
      }
      unawaited(_loadAd(width: width, runtimeState: runtimeState));
    });
  }

  Future<void> _loadAd({
    required int width,
    required AdsRuntimeState runtimeState,
  }) async {
    if (_isLoading || _hasFailed) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoaded = false;
    });

    final previousAd = _bannerAd;
    _bannerAd = null;
    if (previousAd != null) {
      unawaited(previousAd.dispose());
    }

    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (!mounted) {
        return;
      }
      if (size == null) {
        setState(() {
          _hasFailed = true;
          _isLoading = false;
        });
        return;
      }

      final bannerAd = BannerAd(
        adUnitId: appAdsConfig().adUnitIdFor(widget.placement),
        size: size,
        request: runtimeState.canLoadAds
            ? appAdsController().createAdRequest()
            : const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              unawaited(ad.dispose());
              return;
            }

            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
              _isLoading = false;
              _loadedWidth = width;
              _loadedNonPersonalizedAds = runtimeState.nonPersonalizedAds;
            });
          },
          onAdFailedToLoad: (ad, error) {
            unawaited(ad.dispose());
            if (!mounted) {
              return;
            }

            setState(() {
              _bannerAd = null;
              _isLoaded = false;
              _isLoading = false;
              _hasFailed = true;
            });
          },
        ),
      );

      await bannerAd.load();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _bannerAd = null;
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final width =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth.truncate()
                : MediaQuery.sizeOf(context).width.truncate();

            _scheduleLoadIfNeeded(width: width, runtimeState: runtimeState);

            final bannerAd = _bannerAd;
            if (!_isLoaded || bannerAd == null) {
              return const SizedBox.shrink();
            }

            final theme = Theme.of(context);
            return DecoratedBox(
              decoration: BoxDecoration(
                color:
                    theme.bottomNavigationBarTheme.backgroundColor ??
                    theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerTheme.color ?? theme.dividerColor,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: double.infinity,
                  child: AdWidget(ad: bannerAd),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
