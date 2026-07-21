// dart packages
import 'dart:io' show Platform;

// flutter packages
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

// project packages
import 'package:iou/main.dart';
import 'package:iou/colors.dart';

import 'package:iou/services/firebase.dart';
import 'package:iou/services/iap.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseAuthenticationServices firebaseAuthenticationServicesRef =
      FirebaseAuthenticationServices();
  InAppPurchasesServices inAppPurchasesServicesRef = InAppPurchasesServices.instance;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Text(
                t('settings'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: whiteTextColor,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 40)),

              // Account section
              ValueListenableBuilder<bool>(
                valueListenable: loggedIn,
                builder: (context, isLoggedIn, _) {
                  if (!isLoggedIn) {
                    return Column(
                      children: [
                        Text(
                          t('notLoggedIn'),
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            color: lightTextColor,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 20)),
                        GestureDetector(
                          onTap: () async {
                            // Trigger Google sign in from here
                            final BuildContext dialogContext = context;
                            final auth = await firebaseAuthenticationServicesRef
                                .signInWithGoogle(dialogContext);
                            if (auth != null && dialogContext.mounted) {
                              userID = auth.user!.uid;
                              avatarUrl = auth.user!.photoURL;

                              // Identify with RevenueCat so purchases/entitlements are tied to this user
                              if (Platform.isAndroid || Platform.isIOS) {
                                try {
                                  await InAppPurchasesServices.instance.identify(userID!);
                                } catch (_) {}
                              }

                              // Pull cloud data (or push local data) now that we're logged in
                              try {
                                final fs = FirebaseServices();
                                await fs.syncIOUDataOnLogin();
                                await fs.loadAdFreeStatusFromCloud();
                              } catch (_) {}

                              // Force the main screen to refresh from the (now-updated) SharedPreferences
                              // The 300ms poll will pick it up quickly, but we nudge it here too.
                              if (dialogContext.mounted) {
                                // Pop will cause the home page to stay mounted; the timer will refresh.
                                // Nothing else needed.
                              }
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.7,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: yellowDetailColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                t('signInGoogle'),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 18,
                                  color: darkTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            (avatarUrl != null && avatarUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(avatarUrl!)
                                : null,
                        child:
                            (avatarUrl == null || avatarUrl!.isEmpty)
                                ? const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 12)),
                      Text(
                        t('loggedIn'),
                        style: GoogleFonts.bebasNeue(
                          fontSize: 18,
                          color: whiteTextColor,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 30)),

                      // Disable Ads — hide once purchased
                      ValueListenableBuilder<bool>(
                        valueListenable: adFree,
                        builder: (context, isAdFree, _) {
                          if (isAdFree) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await inAppPurchasesServicesRef.showPaywall();
                                },
                                child: Container(
                                  width: screenWidth * 0.75,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: yellowDetailColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      t('disableAds'),
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 17,
                                        color: darkTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(bottom: 16)),
                            ],
                          );
                        },
                      ),

                      // Sign out
                      GestureDetector(
                        onTap: () async {
                          final BuildContext dialogContext = context;
                          await firebaseAuthenticationServicesRef
                              .googleSignOut();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: Container(
                          width: screenWidth * 0.5,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              t('signOut'),
                              style: GoogleFonts.bebasNeue(
                                fontSize: 18,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Padding(padding: EdgeInsets.only(bottom: 30)),

              // Language picker
              _buildSectionLabel("Language"),
              GestureDetector(
                onTap: () => _showLanguagePicker(context),
                child: Container(
                  width: screenWidth * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        supportedLanguages[languageCodes.indexOf(currentLanguage)],
                        style: GoogleFonts.bebasNeue(
                          fontSize: 18,
                          color: whiteTextColor,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    ],
                  ),
                ),
              ),

              const Padding(padding: EdgeInsets.only(bottom: 20)),

              // Currency picker
              _buildSectionLabel("Currency"),
              GestureDetector(
                onTap: () => _showCurrencyPicker(context),
                child: Container(
                  width: screenWidth * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$currentCurrency ($currencySymbol)",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 18,
                          color: whiteTextColor,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  t('close'),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                    color: lightTextColor,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Text(
          text,
          style: GoogleFonts.bebasNeue(
            fontSize: 16,
            color: lightTextColor,
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: mainColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.only(top: 12)),
              for (int i = 0; i < supportedLanguages.length; i++)
                ListTile(
                  title: Text(
                    supportedLanguages[i],
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      color: languageCodes[i] == currentLanguage
                          ? yellowDetailColor
                          : whiteTextColor,
                    ),
                  ),
                  trailing: languageCodes[i] == currentLanguage
                      ? Icon(Icons.check, color: yellowDetailColor)
                      : null,
                  onTap: () async {
                    await setLanguage(languageCodes[i]);
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: mainColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.only(top: 12)),
              for (final cur in supportedCurrencies)
                ListTile(
                  title: Text(
                    "$cur (${_symbolFor(cur)})",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      color: cur == currentCurrency
                          ? yellowDetailColor
                          : whiteTextColor,
                    ),
                  ),
                  trailing: cur == currentCurrency
                      ? Icon(Icons.check, color: yellowDetailColor)
                      : null,
                  onTap: () async {
                    await setCurrency(cur);
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  String _symbolFor(String cur) {
    switch (cur) {
      case 'EUR':
        return '\u20AC'; // €
      case 'JPY':
        return '\u00A5'; // ¥
      case 'GBP':
        return '\u00A3'; // £
      case 'AUD':
        return 'A\$';
      default:
        return '\$';
    }
  }
}

