//  dart packages
import 'dart:async';
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
  FirebaseServices firebaseServices = FirebaseServices();

  // Initialize the purchasing service
  Future<void> init() async {
    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(
        dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? '',
      );
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(
        dotenv.env['REVENUECAT_APPLE_KEY'] ?? '',
      );
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  Future<void> showPaywall() async {
    await RevenueCatUI.presentPaywallIfNeeded(
      'Ad Free',
    );
  }

  // Load available products
  Future<List<StoreProduct>> loadProducts() async {
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
      return [];
    }
  }

  // Check if user has ad-free entitlement (subscription or lifetime)
  Future<void> isAdFreeActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      bool isActive = customerInfo.entitlements.active.containsKey('Ad Free');
      if (isActive) {
        adFree = true;
        firebaseServices.setAdFreeStatus(true);
      } else {
        adFree = false;
        firebaseServices.setAdFreeStatus(false);
      }
    } catch (e) {
      //print('Error checking ad free status: $e');
    }
  }
}