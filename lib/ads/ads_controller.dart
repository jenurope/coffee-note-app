import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_manager.dart';

enum AdsAvailability { disabled, loading, ready, blocked, error }

class AdsRuntimeState {
  const AdsRuntimeState({
    required this.availability,
    this.nonPersonalizedAds = false,
    this.consentStatus = ConsentStatus.unknown,
    this.privacyOptionsRequirementStatus =
        PrivacyOptionsRequirementStatus.unknown,
    this.message,
  });

  const AdsRuntimeState.disabled({this.message})
    : availability = AdsAvailability.disabled,
      nonPersonalizedAds = false,
      consentStatus = ConsentStatus.unknown,
      privacyOptionsRequirementStatus = PrivacyOptionsRequirementStatus.unknown;

  final AdsAvailability availability;
  final bool nonPersonalizedAds;
  final ConsentStatus consentStatus;
  final PrivacyOptionsRequirementStatus privacyOptionsRequirementStatus;
  final String? message;

  bool get canLoadAds => availability == AdsAvailability.ready;
}

class AdsController extends ValueNotifier<AdsRuntimeState> {
  AdsController({AdsRuntimeState? initialState})
    : super(initialState ?? const AdsRuntimeState.disabled());

  void setDisabled({String? message}) {
    value = AdsRuntimeState.disabled(message: message);
  }

  void setLoading() {
    value = const AdsRuntimeState(availability: AdsAvailability.loading);
  }

  void setReady(ConsentSnapshot snapshot) {
    value = AdsRuntimeState(
      availability: AdsAvailability.ready,
      nonPersonalizedAds: snapshot.shouldUseNonPersonalizedAds,
      consentStatus: snapshot.consentStatus,
      privacyOptionsRequirementStatus: snapshot.privacyOptionsRequirementStatus,
      message: snapshot.formErrorMessage,
    );
  }

  void setBlocked(ConsentSnapshot snapshot) {
    value = AdsRuntimeState(
      availability: AdsAvailability.blocked,
      nonPersonalizedAds: snapshot.shouldUseNonPersonalizedAds,
      consentStatus: snapshot.consentStatus,
      privacyOptionsRequirementStatus: snapshot.privacyOptionsRequirementStatus,
      message: snapshot.formErrorMessage,
    );
  }

  void setError(String message) {
    value = AdsRuntimeState(
      availability: AdsAvailability.error,
      message: message,
    );
  }

  AdRequest createAdRequest() {
    return AdRequest(nonPersonalizedAds: value.nonPersonalizedAds);
  }
}
