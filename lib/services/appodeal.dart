import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import 'package:iou/auth/secrets.dart' as secrets;
import 'package:iou/main.dart';

class AppodealServices {
  static int _actionCounter = 0;
  static int _nextInterstitialAt = 5;

  Future<void> init() async {
    bool isAmazonBuild = false;
    String appodealID = secrets.appodealAndroidId;

    if (Platform.isIOS) {
      appodealID = secrets.appodealIosId;
    } else if (isAmazonBuild) {
      appodealID = secrets.appodealAmazonId;
    }

    final initialization = Completer<void>();

    Appodeal.setTesting(false);
    Appodeal.setAutoCache(AppodealAdType.Interstitial, true);
    Appodeal.initialize(
      appKey: appodealID,
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.MREC,
      ],
      onInitializationFinished: (_) {
        if (!initialization.isCompleted) {
          initialization.complete();
        }
      },
    );

    await initialization.future;
  }

  Future<bool> showInterstitial() async {
    if (adFree.value) return false;
    if (await Appodeal.canShow(AppodealAdType.Interstitial)) {
      await Appodeal.show(AppodealAdType.Interstitial);
      return true;
    }
    return false;
  }

  /// Call this after every monetizable user action:
  /// creation, editing amounts, addition/removal of money, deletion.
  /// Shows an interstitial after 5 actions (and every 5 thereafter) unless adFree.
  /// If an ad is not ready exactly on the 5th action we keep trying on following
  /// actions until one is shown, then schedule the next at +5.
  Future<void> recordAction() async {
    if (adFree.value) return;

    _actionCounter++;

    if (_actionCounter >= _nextInterstitialAt) {
      final didShow = await showInterstitial();
      if (didShow) {
        _nextInterstitialAt += 5;
      }
      // If not shown yet (ad not cached/ready), we will attempt again on the next action(s)
      // without advancing the threshold. This ensures an interstitial appears after ~5 actions.
    }
  }

  /// Returns a banner ad widget for placement above the transactions list.
  /// Returns an empty widget when the user is ad-free or on unsupported platforms.
  Widget buildBanner() {
    if (adFree.value) {
      return const SizedBox.shrink();
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SizedBox.shrink();
    }
    return const AppodealBanner(adSize: AppodealBannerSize.BANNER);
  }
}
