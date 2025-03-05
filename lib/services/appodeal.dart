import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AppodealServices {
	init() async {
		Appodeal.initialize(
    appKey: "YOUR_APPODEAL_APP_KEY",
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
