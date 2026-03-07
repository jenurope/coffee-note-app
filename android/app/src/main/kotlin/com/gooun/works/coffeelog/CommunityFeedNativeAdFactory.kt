package com.gooun.works.coffeelog

import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class CommunityFeedNativeAdFactory(
    private val layoutInflater: LayoutInflater,
) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>,
    ): NativeAdView {
        val adView = layoutInflater.inflate(
            R.layout.ad_community_native,
            null,
        ) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)

        adView.headlineView = headlineView
        adView.bodyView = bodyView
        adView.advertiserView = advertiserView
        adView.iconView = iconView

        headlineView.text = nativeAd.headline

        val body = nativeAd.body
        bodyView.text = body.orEmpty()
        bodyView.visibility = if (body.isNullOrBlank()) View.GONE else View.VISIBLE

        val advertiser = nativeAd.advertiser
        advertiserView.text = advertiser.orEmpty()
        advertiserView.visibility = if (advertiser.isNullOrBlank()) View.GONE else View.VISIBLE

        val icon = nativeAd.icon
        if (icon == null) {
            iconView.setImageDrawable(null)
            iconView.visibility = View.GONE
        } else {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        }

        adView.setNativeAd(nativeAd)
        return adView
    }
}
