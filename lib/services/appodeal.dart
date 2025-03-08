import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import 'package:iou/auth/secrets.dart';

class AppodealServices {
	init() async {
		Appodeal.initialize(
    appKey: appodealID,
    adTypes: [
      AppodealAdType.Interstitial, 
      AppodealAdType.Banner,
      AppodealAdType.MREC
    ]);
    Appodeal.setTesting(false);
	}

	showInterstitial() async {
		Appodeal.show(AppodealAdType.Interstitial);
	}
}
