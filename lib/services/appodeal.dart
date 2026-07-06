import 'dart:async';
import 'dart:io';

import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import 'package:iou/auth/secrets.dart' as secrets;

class AppodealServices {
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

  Future<void> showInterstitial() async {
    if (await Appodeal.canShow(AppodealAdType.Interstitial)) {
      await Appodeal.show(AppodealAdType.Interstitial);
    }
  }
}