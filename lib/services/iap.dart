//  dart packages
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

//  flutter packages

//  third-party packages
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//  project packages
import 'package:iou/main.dart';

import 'package:iou/services/firebase.dart';

String monthlyAdFreeID = 'iou_ad_free_monthly';
String lifetimeAdFreeID = 'iou_ad_free_lifetime';

class InAppPurchasesServices {
  InAppPurchasesServices._internal();
  static final InAppPurchasesServices _instance = InAppPurchasesServices._internal();

  /// Always returns the same singleton instance so configuration state is shared.
  factory InAppPurchasesServices() => _instance;

  /// Convenience static accessor: InAppPurchasesServices.instance
  static InAppPurchasesServices get instance => _instance;

  FirebaseServices firebaseServices = FirebaseServices();

  bool _isConfigured = false;

  // Initialize the purchasing service
  Future<void> init() async {
    if (_isConfigured) return;

    String? apiKey;
    if (Platform.isAndroid) {
      apiKey = dotenv.env['REVENUECAT_GOOGLE_KEY'];
    } else if (Platform.isIOS) {
      apiKey = dotenv.env['REVENUECAT_APPLE_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      developer.log(
        'RevenueCat: No API key found for ${Platform.operatingSystem}. '
        'Check your .env file (REVENUECAT_GOOGLE_KEY / REVENUECAT_APPLE_KEY).',
        name: 'IAP',
      );
      return;
    }

    // Basic sanity check for the public SDK key format
    final isValidGoogle = Platform.isAndroid && apiKey.startsWith('goog_');
    final isValidApple = Platform.isIOS && apiKey.startsWith('appl_');

    if (!isValidGoogle && !isValidApple) {
      developer.log(
        'RevenueCat: API key has invalid format: "$apiKey". '
        'Google keys must start with "goog_", Apple keys with "appl_".',
        name: 'IAP',
      );
      return;
    }

    try {
      // Enable verbose logs during development (safe to leave or remove later)
      await Purchases.setLogLevel(LogLevel.debug);

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _isConfigured = true;

      developer.log('RevenueCat configured successfully.', name: 'IAP');
    } catch (e) {
      developer.log('RevenueCat configure failed: $e', name: 'IAP', error: e);
    }
  }

  Future<void> showPaywall() async {
    if (!_isConfigured) {
      // Attempt on-demand configuration so the button works even if tapped very early.
      await init();
    }
    if (!_isConfigured) {
      developer.log('RevenueCat: showPaywall() still not configured after init attempt.', name: 'IAP');
      return;
    }
    try {
      await RevenueCatUI.presentPaywallIfNeeded('Ad Free');
      // Refresh entitlement status immediately after paywall closes so UI
      // (e.g. hiding the Disable Ads button) can update without waiting for the timer.
      await isAdFreeActive();
    } catch (e) {
      developer.log('RevenueCat: showPaywall failed: $e', name: 'IAP', error: e);
    }
  }

  // Load available products
  Future<List<StoreProduct>> loadProducts() async {
    if (!_isConfigured) return [];
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages
            .map((pkg) => pkg.storeProduct)
            .toList();
      }
      return [];
    } catch (e) {
      developer.log('RevenueCat: loadProducts failed: $e', name: 'IAP', error: e);
      return [];
    }
  }

  // Check if user has ad-free entitlement (subscription or lifetime)
  Future<void> isAdFreeActive() async {
    if (!_isConfigured) return;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      bool isActive = customerInfo.entitlements.active.containsKey('Ad Free');
      if (isActive) {
        adFree.value = true;
        firebaseServices.setAdFreeStatus(true);
      } else {
        adFree.value = false;
        firebaseServices.setAdFreeStatus(false);
      }
    } catch (e) {
      developer.log('RevenueCat: isAdFreeActive failed: $e', name: 'IAP', error: e);
    }
  }

  /// Identify the current user with RevenueCat using your own stable ID (Firebase UID).
  /// This ensures purchases are attached to the user and restore correctly across devices.
  Future<void> identify(String appUserID) async {
    if (appUserID.isEmpty) return;
    if (!_isConfigured) {
      await init();
    }
    if (!_isConfigured) return;
    try {
      await Purchases.logIn(appUserID);
      developer.log('RevenueCat: identified user $appUserID', name: 'IAP');
      // Refresh status right away
      await isAdFreeActive();
    } catch (e) {
      developer.log('RevenueCat identify failed: $e', name: 'IAP', error: e);
    }
  }
}