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
  InAppPurchasesServices inAppPurchasesServicesRef = InAppPurchasesServices();

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
                "Settings",
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
                          "Not logged in",
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
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.7,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            decoration: BoxDecoration(
                              color: yellowDetailColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Sign in with Google",
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
                        backgroundImage: (avatarUrl != null &&
                                avatarUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(avatarUrl!)
                            : null,
                        child: (avatarUrl == null || avatarUrl!.isEmpty)
                            ? const Icon(Icons.person,
                                size: 36, color: Colors.white)
                            : null,
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 12)),
                      Text(
                        "Logged in",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 18,
                          color: whiteTextColor,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 30)),

                      // Disable Ads (one-time 3.99 or 0.99/mo)
                      GestureDetector(
                        onTap: () {
                          inAppPurchasesServicesRef.showPaywall();
                        },
                        child: Container(
                          width: screenWidth * 0.75,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          decoration: BoxDecoration(
                            color: yellowDetailColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Disable Ads • 3.99 or 0.99/mo",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 17,
                                color: darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Padding(padding: EdgeInsets.only(bottom: 16)),

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
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Out",
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

              const Spacer(),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Close",
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
}