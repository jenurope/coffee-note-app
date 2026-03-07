import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentSnapshot {
  const ConsentSnapshot({
    required this.canRequestAds,
    required this.consentStatus,
    required this.privacyOptionsRequirementStatus,
    this.formErrorMessage,
  });

  final bool canRequestAds;
  final ConsentStatus consentStatus;
  final PrivacyOptionsRequirementStatus privacyOptionsRequirementStatus;
  final String? formErrorMessage;

  bool get shouldUseNonPersonalizedAds {
    return canRequestAds &&
        consentStatus != ConsentStatus.obtained &&
        consentStatus != ConsentStatus.notRequired;
  }
}

abstract class ConsentManager {
  Future<ConsentSnapshot> gatherConsent({void Function(String message)? log});

  Future<void> showPrivacyOptionsForm();
}

class UmpConsentManager implements ConsentManager {
  UmpConsentManager();

  @override
  Future<ConsentSnapshot> gatherConsent({
    void Function(String message)? log,
  }) async {
    final logger = log ?? (_) {};
    final completer = Completer<ConsentSnapshot>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            if (formError != null) {
              logger('UMP consent form error: ${formError.message}');
            }
            if (completer.isCompleted) {
              return;
            }
            completer.complete(await _snapshot(formError: formError));
          });
        } catch (error) {
          logger('UMP consent form exception: $error');
          if (completer.isCompleted) {
            return;
          }
          completer.complete(await _snapshot(errorMessage: '$error'));
        }
      },
      (formError) async {
        logger('UMP consent info update failed: ${formError.message}');
        if (completer.isCompleted) {
          return;
        }
        completer.complete(await _snapshot(formError: formError));
      },
    );

    return completer.future;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        completer.completeError(StateError(formError.message));
        return;
      }
      completer.complete();
    });
    return completer.future;
  }

  Future<ConsentSnapshot> _snapshot({
    FormError? formError,
    String? errorMessage,
  }) async {
    final canRequestAds = await ConsentInformation.instance.canRequestAds();
    final consentStatus = await ConsentInformation.instance.getConsentStatus();
    final privacyOptionsRequirementStatus = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();

    return ConsentSnapshot(
      canRequestAds: canRequestAds,
      consentStatus: consentStatus,
      privacyOptionsRequirementStatus: privacyOptionsRequirementStatus,
      formErrorMessage: formError?.message ?? errorMessage,
    );
  }
}
