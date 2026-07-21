// dart packages
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// flutter packages
import 'package:flutter/material.dart';

// third-party packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// project packages
import 'package:iou/main.dart';

class FirebaseServices {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  Future<void> updateLastLogin() async {
    try {
      await dbRef.child("users/$userID").update({
        "lastLogin": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      //print("Failed to update users last login: $e");
    }
  }

  Future<void> getLastCheckin() async {
    final snapshot =
        await dbRef.child("users/$userID/lastCheckin").once();
    var value = snapshot.snapshot.value;
    if (value is int) {
      lastCheckin.value = value;
    } else {
      //print("Database snapshot is not in expected format.");
    }
  }

  Future<void> setLastCheckin() async {
    try {
      await dbRef.child("users/$userID/lastCheckin").runTransaction((
        data,
      ) {
        data = DateTime.now().millisecondsSinceEpoch;
        return Transaction.success(data);
      });
      await getLastCheckin();
    } catch (e) {
      //print("Failed to update user last checkin: $e");
    }
  }

  Future<void> getEarningsData() async {
    final snapshot = await dbRef.child("iou").once();
    var value = snapshot.snapshot.value as Map?;
    if (value != null) {
      appEarnings = (value["appEarnings"] as num?)?.toDouble() ?? 0.0;
      liquidityPercentage =
          (value["liquidityPercentage"] as num?)?.toDouble() ?? 0.0;
    } else {
      //print("Database snapshot is not in expected format.");
    }
  }

  void getDROPs() {
    dbRef.child("users/$userID/drops").onValue.listen((
      DatabaseEvent event,
    ) async {
      var snapshot = event.snapshot.value;
      if (snapshot is int) {
        drops.value = snapshot;
      } else {
        //print("Database snapshot is not in expected format.");
      }
    });
  }

  Future<void> addDROPs(int amount) async {
    final multiplier = getMultiplier();
    final increment = amount * multiplier;
    final referralReward = (amount * 0.15).toInt();

    try {
      await Future.wait([
        dbRef.child("users/$userID/drops").runTransaction((data) {
          final current = (data as int?) ?? 0;
          return Transaction.success(current + increment);
        }),
        dbRef.child("iou/drops").runTransaction((data) {
          final current = (data as int?) ?? 0;
          return Transaction.success(current + increment);
        }),
        if (referredBy.isNotEmpty)
          dbRef.child("iou/referrals/$referredBy/toCredit").runTransaction(
            (data) {
              final current = (data as int?) ?? 0;
              return Transaction.success(current + referralReward);
            },
          ),
      ]);
    } catch (e) {
      // Handle/log error if needed
    }
  }

  Future<void> removeDrops(int amount) async {
    try {
      await dbRef.child("users/$userID/drops").runTransaction((data) {
        final currentDrops = (data as int?) ?? 0;
        final newDrops = max(0, currentDrops - amount);
        if (data is int) {
          drops.value = newDrops;
        }
        return Transaction.success(newDrops);
      });

      await dbRef.child("iou/drops").runTransaction((data) {
        final currentTotalDrops = (data as int?) ?? 0;
        final newTotalDrops = max(0, currentTotalDrops - amount);
        if (data is int) {
          totalDrops.value = newTotalDrops;
        }
        return Transaction.success(newTotalDrops);
      });
    } catch (e) {
      // Handle/log error if needed
    }
  }

  Future<Map<String, dynamic>> getSecondaryTokenData() async {
    try {
      DatabaseEvent event = await dbRef.child('iou/secondaryTokens').once();
      var snapshot = event.snapshot.value;
      return jsonDecode(jsonEncode(snapshot));
    } catch (e) {
      return {};
    }
  }

  Future<void> getSecondaryTokens() async {
    final event =
        await dbRef.child('users/$userID/secondaryTokens').once();
    final data = event.snapshot.value;

    if (data != null && data is Map) {
      final Map<String, double> snapshot = data.map((key, value) {
        if (value is num) {
          return MapEntry(key.toString(), value.toDouble());
        } else {
          return MapEntry(key.toString(), 0.0);
        }
      });

      final sortedKeys =
          snapshot.keys.toList()..sort((a, b) {
            final valueA = snapshot[a] ?? 0;
            final valueB = snapshot[b] ?? 0;
            return valueB.compareTo(valueA);
          });

      secondaryTokenBalance.value = snapshot;
      sortedTokenKeyList = sortedKeys;
    }
  }

  Future<void> addSecondaryToken() async {
    Map<String, dynamic> secondaryTokenData = await getSecondaryTokenData();
    List secondaryTokenNameList = secondaryTokenData.keys.toList();
    String randomTokenName =
        secondaryTokenNameList[Random().nextInt(secondaryTokenNameList.length)];
    int tokenAmount = secondaryTokenData[randomTokenName]['reward'];

    int tokenSupply = secondaryTokenData[randomTokenName]['supply'];
    if (tokenSupply > tokenAmount) {
      try {
        dbRef
            .child('iou/secondaryTokens/$randomTokenName/supply')
            .runTransaction((supply) {
              if (supply is num) supply -= tokenAmount;
              return Transaction.success(supply);
            });

        dbRef
            .child('users/$userID/secondaryTokens/$randomTokenName')
            .runTransaction((balance) {
              if (balance != null && balance is num) {
                balance += tokenAmount;
              } else {
                balance = tokenAmount;
              }
              return Transaction.success(balance);
            });
      } catch (e) {
        //print('Error with secondary token data: $e');
      }
    }
  }

  Future<void> getActionData() async {
    final event = await dbRef.child("users/$userID").once();
    var snapshot = event.snapshot.value;
    if (snapshot is Map) {
      energyLVL.value = snapshot["energyLevel"] ?? 1;
      energyRechargeLVL.value = snapshot["energyRechargeLevel"] ?? 1;
      clickLVL.value = snapshot["clickLevel"] ?? 1;
      autoClickLVL.value = snapshot["autoClickLevel"] ?? 0;
    }
  }

  updateActionData(String type, int value) async {
    try {
      await dbRef.child("users/$userID/$type").runTransaction((data) {
        return Transaction.success(value);
      });
    } catch (e) {
      //print("Failed to update $type: $e");
    }
  }

  checkRefCodeExists(String refCode) async {
    final snapshot = await dbRef.child("iou/referrals/$refCode").once();
    return snapshot.snapshot.value != null;
  }

  addReferredBy(String refCode) async {
    try {
      await dbRef.child("users/$userID/referredBy").set(refCode);
    } catch (e) {
      //print("Failed to update user Ref Code: $e");
    }

    try {
      await dbRef.child("iou/referrals/$refCode/refAmount").runTransaction(
        (data) {
          if (data is int) {
            data += 1;
          }
          return Transaction.success(data);
        },
      );
    } catch (e) {
      //print("Failed to update $refCode: $e");
    }
  }

  Future<void> _createAndSetReferralCode() async {
    // Placeholder - iou does not use referral codes yet
    await dbRef.child("users/$userID/refCode").set("");
  }

  Future<void> getUserReferralData() async {
    final event = await dbRef.child("users/$userID").once();
    var snapshot = event.snapshot.value;
    if (snapshot is Map) {
      referredBy = snapshot["referredBy"] ?? "";
      userRefCode = snapshot["refCode"] ?? "";
    }
  }

  Future<void> getReferralCountAndEarnings() async {
    if (userRefCode.isEmpty) {
      await getUserReferralData();
    }
    final event = await dbRef.child("iou/referrals/$userRefCode").once();
    var snapshot = event.snapshot.value;
    if (snapshot is Map) {
      userReferralCount = snapshot["refAmount"] ?? 0;
      userReferralEarnings.value = snapshot["credited"] ?? 0;
    }
  }

  Future<void> creditReferralDrops() async {
    final event =
        await dbRef.child("iou/referrals/$userRefCode/toCredit").once();
    var snapshot = event.snapshot.value;
    if (snapshot is int && snapshot != 0) {
      try {
        await dbRef
            .child("iou/referrals/$userRefCode/credited")
            .runTransaction((data) {
              data = userReferralEarnings.value + snapshot;
              if (data is int) {
                addDROPs(data);
              }
              return Transaction.success(userReferralEarnings.value + snapshot);
            });
        await dbRef
            .child("iou/referrals/$userRefCode/toCredit")
            .runTransaction((data) {
              data = 0;
              return Transaction.success(0);
            });
      } catch (e) {
        //print("Failed to update credited referral rewards: $e");
      }
    }
  }

  Future<void> getCompletedSponsoredTasks() async {
    final event =
        await dbRef.child("users/$userID/sponsoredTasks").once();
    var snapshot = event.snapshot.value;
    if (snapshot is Map) {
      // Reuse coindrop task flags for parity if needed later
    } else {
      // default false state handled by globals
    }
  }

  Future<void> updateCompletedSponsoredTasks(
    String taskID,
    bool completed,
  ) async {
    try {
      await dbRef
          .child("users/$userID/sponsoredTasks/$taskID")
          .set(completed);
    } catch (e) {
      //print("Failed to update completed sponsored task $taskID: $e");
    }
  }

  setAdFreeStatus(bool status) async {
    try {
      await dbRef.child("users/$userID/adFreeStatus").set(status);
      await dbRef
          .child("users/$userID/adFreeStatusTime")
          .set(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      //print("Failed to update ad free status: $e");
    }
  }

  /// Load adFreeStatus from cloud (if present) and apply it to the reactive flag.
  /// This enables hiding the "Disable Ads" button after a purchase on another device.
  Future<void> loadAdFreeStatusFromCloud() async {
    if (userID == null || userID!.isEmpty) return;
    try {
      final snap = await dbRef.child("users/$userID/adFreeStatus").once();
      final val = snap.snapshot.value;
      if (val is bool) {
        adFree.value = val;
      }
    } catch (_) {
      // Non-fatal; local/RevenueCat value will be used.
    }
  }

  /// Save the core IOU app data (username + people/money + transactions) to RTDB.
  /// Safe to call even if not logged in (no-op).
  Future<void> saveIOUData({
    String? username,
    Map<String, dynamic>? moneyData,
    Map<String, dynamic>? transactionData,
  }) async {
    if (userID == null || userID!.isEmpty) return;
    final Map<String, dynamic> updates = {};
    if (username != null) updates['username'] = username;
    if (moneyData != null) updates['moneydata'] = moneyData;
    if (transactionData != null) updates['transactiondata'] = transactionData;

    if (updates.isNotEmpty) {
      try {
        await dbRef.child("users/$userID").update(updates);
      } catch (_) {
        // Silent fail is acceptable; local data is still saved.
      }
    }
  }

  /// Load previously saved IOU data from RTDB for the current user.
  Future<Map<String, dynamic>?> loadIOUData() async {
    if (userID == null || userID!.isEmpty) return null;
    try {
      final event = await dbRef.child("users/$userID").once();
      final value = event.snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    } catch (_) {}
    return null;
  }

  /// Called after login (or on silent sign-in check).
  /// - If cloud data exists → pull it into SharedPreferences (UI will see it on next loadData).
  /// - If no cloud data → push current local data up so it starts being backed up.
  Future<void> syncIOUDataOnLogin() async {
    if (userID == null || userID!.isEmpty) return;

    try {
      await updateLastLogin();
    } catch (_) {}

    final cloud = await loadIOUData();
    final prefs = await SharedPreferences.getInstance();

    if (cloud != null) {
      final hasCoreCloudData = cloud['moneydata'] != null ||
          cloud['transactiondata'] != null ||
          cloud['username'] != null;

      if (hasCoreCloudData) {
        // Cloud data wins on login
        if (cloud['username'] is String) {
          final cloudUsername = cloud['username'] as String;
          if (cloudUsername.isNotEmpty) {
            await prefs.setString('username', cloudUsername);
          }
        }
        if (cloud['moneydata'] is Map) {
          await prefs.setString('moneydata', jsonEncode(cloud['moneydata']));
        }
        if (cloud['transactiondata'] is Map) {
          await prefs.setString('transactiondata', jsonEncode(cloud['transactiondata']));
        }
      } else {
        // No core data in cloud yet — push local data up
        final localUsername = prefs.getString('username');
        final localMoneyStr = prefs.getString('moneydata');
        final localTxStr = prefs.getString('transactiondata');

        Map<String, dynamic>? localMoneyMap;
        Map<String, dynamic>? localTxMap;

        if (localMoneyStr != null && localMoneyStr.isNotEmpty) {
          try {
            localMoneyMap = jsonDecode(localMoneyStr) as Map<String, dynamic>;
          } catch (_) {}
        }
        if (localTxStr != null && localTxStr.isNotEmpty) {
          try {
            localTxMap = jsonDecode(localTxStr) as Map<String, dynamic>;
          } catch (_) {}
        }

        await saveIOUData(
          username: (localUsername != null && localUsername.isNotEmpty) ? localUsername : null,
          moneyData: localMoneyMap,
          transactionData: localTxMap,
        );
      }
    } else {
      // No (or empty) cloud data — upload whatever is currently stored locally
      final localUsername = prefs.getString('username');
      final localMoneyStr = prefs.getString('moneydata');
      final localTxStr = prefs.getString('transactiondata');

      Map<String, dynamic>? localMoneyMap;
      Map<String, dynamic>? localTxMap;

      if (localMoneyStr != null && localMoneyStr.isNotEmpty) {
        try {
          localMoneyMap = jsonDecode(localMoneyStr) as Map<String, dynamic>;
        } catch (_) {}
      }
      if (localTxStr != null && localTxStr.isNotEmpty) {
        try {
          localTxMap = jsonDecode(localTxStr) as Map<String, dynamic>;
        } catch (_) {}
      }

      await saveIOUData(
        username: (localUsername != null && localUsername.isNotEmpty) ? localUsername : null,
        moneyData: localMoneyMap,
        transactionData: localTxMap,
      );
    }
  }

  int getMultiplier() {
    int multiplier = 0;
    if (brigthSharingActive.value) {
      multiplier += 2;
    }
    if (adFree.value) {
      multiplier += 100;
    }

    if (multiplier == 0) return 1;
    return multiplier;
  }
}

class FirebaseAuthenticationServices {
  // Use the singleton instance consistently
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Anonymous Sign In (optional - gated by remote flag like coindrop)
  Future<UserCredential?> anonymousSignIn() async {
    final snapshot =
        await FirebaseDatabase.instance.ref().child("iou/anonAuth").once();
    bool anonAuth = snapshot.snapshot.value as bool? ?? false;

    if (anonAuth) {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      loggedIn.value = true;
      return userCredential;
    }
    return null;
  }

  // Check if Signed In
  Future<bool> checkSignIn() async {
    return firebaseAuth.currentUser != null;
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Use the class field (singleton) consistently
      // serverClientId = WEB client ID (the one with client_type: 3 in google-services.json)
      await googleSignIn.initialize(
        serverClientId: '1039241873041-tga17qgril98a53ivu331cmbdggs9i5b.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? maybeUser = await googleSignIn.authenticate();
      if (maybeUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      // In google_sign_in 7.x, authentication is a synchronous getter (not a Future)
      final GoogleSignInAccount googleUser = maybeUser;
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'idToken is null. '
          'Verify serverClientId (web client ID) and that the app\'s SHA-1 fingerprint is registered in Firebase Console → Authentication → Sign-in method → Google.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Note: accessToken is not exposed in current GoogleSignInAuthentication on this plugin version.
        // idToken alone is sufficient when serverClientId (web client ID) is provided.
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      loggedIn.value = true;
      return userCredential;
    } catch (error, stack) {
      // Log full details
      // ignore: avoid_print
      print('Google Sign-In error: $error');
      // ignore: avoid_print
      print(stack);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account reauth failed: $error'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return null;
    }
  }

  // Google Sign Out
  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    loggedIn.value = false;
    resetGlobalVariables();
  }

  void resetGlobalVariables() async {
    loggedIn.value = false;
    userID = null;
    avatarUrl = null;
    userRefCode = "";
    userReferralCount = 0;
    userReferralEarnings.value = 0;
    referredBy = "";
    drops.value = 0;
    energyLVL.value = 1;
    remainingEnergy.value = 0;
    energyRechargeLVL.value = 1;
    clickLVL.value = 1;
    autoClickLVL.value = 0;
    lastCheckin.value = 0;
    adFree.value = false;

    // Coindrop task flags (harmless if unused in iou)
    storeRatingTaskCompleted.value = true;
    clickbeebotTaskCompleted.value = true;
    socialgiftTaskCompleted.value = true;
    socialmoneyTaskCompleted.value = true;
    winwalkTaskCompleted.value = true;
    wewardTaskCompleted.value = true;
    krakenTaskCompleted.value = true;
    bbvaTaskCompleted.value = true;
    klarnaTaskCompleted.value = true;
    bitcoincashgiveawayTaskCompleted.value = true;
    litecoingiveawayTaskCompleted.value = true;
    iouTaskCompleted.value = true;
    clusterminerTaskCompleted.value = true;
    cointradeTaskCompleted.value = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('energy');
  }
}

class FirebaseNotificationServices {}