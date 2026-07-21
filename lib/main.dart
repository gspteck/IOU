// dart packages
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// flutter packages
import 'package:flutter/material.dart';

// third-party packages
import 'package:intl/intl.dart';
import 'package:feedback/feedback.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

// project packages
import 'package:iou/colors.dart';

import 'package:iou/elements/add_button.dart';
import 'package:iou/elements/money_box.dart';
import 'package:iou/elements/transaction_box.dart';

import 'package:iou/services/feedback.dart';
import 'package:iou/services/appodeal.dart';
import 'package:iou/services/firebase.dart';
import 'package:iou/services/iap.dart';
import 'package:iou/screens/settings_screen.dart';

import 'firebase_options.dart';

// Global state (matching coindrop structure)
ValueNotifier<bool> loggedIn = ValueNotifier<bool>(false);
late String? userID;
String? avatarUrl;
final ValueNotifier<bool> adFree = ValueNotifier<bool>(false);

// Stub globals referenced by shared firebase.dart code
ValueNotifier<int> drops = ValueNotifier<int>(0);
ValueNotifier<int> totalDrops = ValueNotifier<int>(0);
ValueNotifier<Map<String, double>> secondaryTokenBalance =
    ValueNotifier<Map<String, double>>({});
List sortedTokenKeyList = [];
ValueNotifier<int> energyLVL = ValueNotifier<int>(1);
ValueNotifier<int> remainingEnergy = ValueNotifier<int>(0);
ValueNotifier<int> energyRechargeLVL = ValueNotifier<int>(1);
ValueNotifier<int> clickLVL = ValueNotifier<int>(1);
ValueNotifier<int> autoClickLVL = ValueNotifier<int>(0);
ValueNotifier<int> lastCheckin = ValueNotifier<int>(0);
ValueNotifier<int> userReferralEarnings = ValueNotifier<int>(0);
String userRefCode = "";
int userReferralCount = 0;
String referredBy = "";
double appEarnings = 0;
double liquidityPercentage = 0;
ValueNotifier<bool> brigthSharingActive = ValueNotifier<bool>(false);

ValueNotifier<bool> storeRatingTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> clickbeebotTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> socialgiftTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> socialmoneyTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> winwalkTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> wewardTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> krakenTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> bbvaTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> klarnaTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> bitcoincashgiveawayTaskCompleted = ValueNotifier<bool>(
  true,
);
ValueNotifier<bool> litecoingiveawayTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> iouTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> clusterminerTaskCompleted = ValueNotifier<bool>(true);
ValueNotifier<bool> cointradeTaskCompleted = ValueNotifier<bool>(true);

// Language & Currency settings (persisted in SharedPreferences)
String currentLanguage = 'en'; // 'en', 'zh', 'es', 'hi', 'it', 'ja'
String currentCurrency = 'USD';

final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');
final ValueNotifier<String> currencyNotifier = ValueNotifier<String>('USD');

const List<String> supportedLanguages = [
  'English',
  'Mandarin Chinese',
  'Spanish',
  'Hindi',
  'Italian',
  'Japanese',
];
const List<String> languageCodes = ['en', 'zh', 'es', 'hi', 'it', 'ja'];

const List<String> supportedCurrencies = ['USD', 'EUR', 'JPY', 'GBP', 'AUD'];

String get currencySymbol {
  switch (currentCurrency) {
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

const Map<String, Map<String, String>> _translations = {
  'en': {
    'hi': 'Hi,',
    'totalOwed': 'Total Owed',
    'tagline': 'T I M E   T O   P A Y   Y O U R   D U E S !',
    'transactions': 'Transactions ',
    'last10': ' (last 10)',
    'usernameHint': 'Username',
    'moneyHint': 'Money',
    'nameHint': 'Name',
    'cancel': 'Cancel',
    'add': 'Add',
    'settings': 'Settings',
    'notLoggedIn': 'Not logged in',
    'loggedIn': 'Logged in',
    'disableAds': 'Disable Ads',
    'signInGoogle': 'Sign in with Google',
    'signOut': 'Sign Out',
    'close': 'Close',
  },
  'zh': {
    'hi': '你好，',
    'totalOwed': '总欠款',
    'tagline': '是时候付清你的债务了！',
    'transactions': '交易记录 ',
    'last10': '（最近10笔）',
    'usernameHint': '用户名',
    'moneyHint': '金额',
    'nameHint': '姓名',
    'cancel': '取消',
    'add': '添加',
    'settings': '设置',
    'notLoggedIn': '未登录',
    'loggedIn': '已登录',
    'disableAds': '禁用广告',
    'signInGoogle': '使用 Google 登录',
    'signOut': '退出登录',
    'close': '关闭',
  },
  'es': {
    'hi': 'Hola,',
    'totalOwed': 'Total Adeudado',
    'tagline': '¡ES HORA DE PAGAR TUS DEUDAS!',
    'transactions': 'Transacciones ',
    'last10': ' (últimas 10)',
    'usernameHint': 'Usuario',
    'moneyHint': 'Dinero',
    'nameHint': 'Nombre',
    'cancel': 'Cancelar',
    'add': 'Agregar',
    'settings': 'Ajustes',
    'notLoggedIn': 'No has iniciado sesión',
    'loggedIn': 'Sesión iniciada',
    'disableAds': 'Desactivar anuncios',
    'signInGoogle': 'Iniciar sesión con Google',
    'signOut': 'Cerrar sesión',
    'close': 'Cerrar',
  },
  'hi': {
    'hi': 'नमस्ते,',
    'totalOwed': 'कुल बकाया',
    'tagline': 'अब समय है अपने बकाये चुकाने का!',
    'transactions': 'लेनदेन ',
    'last10': ' (पिछले 10)',
    'usernameHint': 'उपयोगकर्ता नाम',
    'moneyHint': 'राशि',
    'nameHint': 'नाम',
    'cancel': 'रद्द करें',
    'add': 'जोड़ें',
    'settings': 'सेटिंग्स',
    'notLoggedIn': 'लॉग इन नहीं है',
    'loggedIn': 'लॉग इन है',
    'disableAds': 'विज्ञापन अक्षम करें',
    'signInGoogle': 'Google से साइन इन करें',
    'signOut': 'साइन आउट करें',
    'close': 'बंद करें',
  },
  'it': {
    'hi': 'Ciao,',
    'totalOwed': 'Totale Dovuto',
    'tagline': 'È ORA DI PAGARE I TUOI DEBITI!',
    'transactions': 'Transazioni ',
    'last10': ' (ultime 10)',
    'usernameHint': 'Nome utente',
    'moneyHint': 'Importo',
    'nameHint': 'Nome',
    'cancel': 'Annulla',
    'add': 'Aggiungi',
    'settings': 'Impostazioni',
    'notLoggedIn': 'Non connesso',
    'loggedIn': 'Connesso',
    'disableAds': 'Disabilita annunci',
    'signInGoogle': 'Accedi con Google',
    'signOut': 'Esci',
    'close': 'Chiudi',
  },
  'ja': {
    'hi': 'こんにちは、',
    'totalOwed': '合計未払い額',
    'tagline': '支払いの時間です！',
    'transactions': '取引 ',
    'last10': ' (最新10件)',
    'usernameHint': 'ユーザー名',
    'moneyHint': '金額',
    'nameHint': '名前',
    'cancel': 'キャンセル',
    'add': '追加',
    'settings': '設定',
    'notLoggedIn': 'ログインしていません',
    'loggedIn': 'ログイン中',
    'disableAds': '広告を無効化',
    'signInGoogle': 'Googleでサインイン',
    'signOut': 'サインアウト',
    'close': '閉じる',
  },
};

String t(String key) {
  final code = currentLanguage;
  return _translations[code]?[key] ?? _translations['en']?[key] ?? key;
}

Future<void> setLanguage(String langCode) async {
  currentLanguage = langCode;
  languageNotifier.value = langCode;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', langCode);
}

Future<void> setCurrency(String currencyCode) async {
  currentCurrency = currencyCode;
  currencyNotifier.value = currencyCode;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('currency', currencyCode);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(BetterFeedback(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final numberFormat = NumberFormat("###,###,###.##", "tr_TR");

  TextEditingController usernameTextEditingController = TextEditingController();
  String username = "John Doe";
  bool editingUsername = false;

  double totalOwed = 0;
  String totalOwedInt = "";
  String totalOwedDec = "";

  Map<String, dynamic> moneyData = {"data": []};
  Map<String, dynamic> transactionData = {"data": []};

  late final VoidCallback _langListener;
  late final VoidCallback _curListener;
  late final VoidCallback _adFreeListener;

  @override
  void initState() {
    super.initState();

    AppodealServices as = AppodealServices();
    as.init();

    // Initialize IAP + start subscription status polling (only on mobile)
    if (Platform.isAndroid || Platform.isIOS) {
      InAppPurchasesServices.instance.init();
      Timer.periodic(const Duration(seconds: 2), (_) => InAppPurchasesServices.instance.isAdFreeActive());
    }

    // Ensure cloud data is synced into SharedPreferences before first loadData
    _initializeData();

    // Live reactivity for language/currency changes (settings)
    _langListener = () {
      if (mounted) setState(() {});
    };
    _curListener = () {
      if (mounted) setState(() {});
    };
    _adFreeListener = () {
      if (mounted) setState(() {});
    };
    languageNotifier.addListener(_langListener);
    currencyNotifier.addListener(_curListener);
    adFree.addListener(_adFreeListener);
  }

  Future<void> _initializeData() async {
    // Wait for auth check + possible cloud→prefs sync so loadData sees fresh data
    await _silentLoginCheck();
    loadData();

    // Keep polling local storage (mutations keep both prefs + cloud in sync)
    Timer.periodic(const Duration(milliseconds: 300), (t) async {
      loadData();
    });
  }

  Future<void> _silentLoginCheck() async {
    FirebaseAuthenticationServices fas = FirebaseAuthenticationServices();
    bool signedIn = await fas.checkSignIn();
    if (signedIn) {
      final user = fas.firebaseAuth.currentUser;
      if (user != null) {
        loggedIn.value = true;
        userID = user.uid;
        avatarUrl = user.photoURL;

        // Identify with RevenueCat so entitlements restore correctly for this user
        if (Platform.isAndroid || Platform.isIOS) {
          try {
            await InAppPurchasesServices.instance.identify(user.uid);
          } catch (_) {}
        }

        // Sync cloud <-> local data on cold start when already logged in
        try {
          final fs = FirebaseServices();
          await fs.syncIOUDataOnLogin();
          // Pull adFreeStatus from cloud for immediate UI (RevenueCat polling will reconcile)
          await fs.loadAdFreeStatusFromCloud();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    usernameTextEditingController.text;
    languageNotifier.removeListener(_langListener);
    currencyNotifier.removeListener(_curListener);
    adFree.removeListener(_adFreeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPaddingHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenAvrg = (screenWidth / 9 + screenHeight / 16) / 2;

    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top White Section
              Container(
                width: screenWidth,
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: topPaddingHeight + screenHeight * 0.04,
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.1),
                        ),
                        !editingUsername
                            ? Text(
                              "${t('hi')} $username.",
                              style: GoogleFonts.bebasNeue(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : SizedBox(
                              width: screenWidth * 0.4,
                              child: TextField(
                                controller: usernameTextEditingController,
                                decoration: InputDecoration(
                                  hintText: t('usernameHint'),
                                  hintStyle: GoogleFonts.bebasNeue(
                                    color: whiteTextColor,
                                  ),
                                ),
                              ),
                            ),
                        IconButton(
                          onPressed: () {
                            if (!editingUsername) {
                              setState(() {
                                editingUsername = true;
                              });
                            } else {
                              editUsername();
                            }
                          },
                          icon: Icon(
                            !editingUsername ? Icons.edit : Icons.check,
                            size: 15,
                            color: darkTextColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            FeedbackServices fs = FeedbackServices();
                            fs.sendFeedback(context);
                          },
                          icon: Icon(Icons.bug_report, color: darkTextColor),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.settings, color: darkTextColor),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.04),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.07),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.8,
                              child: Text(
                                t('totalOwed'),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 30,
                                  color: lightTextColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.8,
                              child: RichText(
                                text: TextSpan(
                                  text: "$currencySymbol$totalOwedInt",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 55,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ",$totalOwedDec",
                                      style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                        color: lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),

                    Container(
                      width: screenWidth * 0.86,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        color: yellowDetailColor,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Bottom Elements
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Text(
                t('tagline'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: whiteTextColor,
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              moneyData["data"].isNotEmpty
                  ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: moneyData["data"].length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 25 : 10,
                            top: 3,
                            right: index == moneyData["data"].length ? 25 : 10,
                            bottom: 3,
                          ),
                          child:
                              index == 0
                                  ? AddButton()
                                  : MoneyBox(
                                    index: index - 1,
                                    bgColor:
                                        moneyBoxColors[moneyData["data"][index -
                                            1]["colorIndex"]],
                                    name: moneyData["data"][index - 1]["name"],
                                    money:
                                        (moneyData["data"][index - 1]["money"]
                                                as num)
                                            .toDouble(),
                                    percentage:
                                        ((moneyData["data"][index - 1]["money"]
                                                        as num)
                                                    .toDouble() /
                                                (totalOwed == 0
                                                    ? 1
                                                    : totalOwed) *
                                                100)
                                            .toInt(),
                                  ),
                        );
                      },
                    ),
                  )
                  : Row(
                    children: [
                      Padding(padding: EdgeInsets.only(right: 25)),
                      AddButton(),
                      const Spacer(),
                    ],
                  ),

              // Banner ad above transactions (only when not ad-free)
              if (!adFree.value)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AppodealServices().buildBanner(),
                ),

              // Transactions
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Row(
                children: [
                  Padding(padding: EdgeInsets.only(right: screenWidth * 0.1)),
                  RichText(
                    text: TextSpan(
                      text: t('transactions'),
                      style: GoogleFonts.bebasNeue(
                        fontSize: 30,
                        color: whiteTextColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: t('last10'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: whiteTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              transactionData["data"].isNotEmpty
                  ? SizedBox(
                    height: 10 * 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          transactionData["data"].length > 10
                              ? 10
                              : transactionData["data"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 25,
                            top: 7,
                            right: 25,
                            bottom: 7,
                          ),
                          child:
                              transactionData["data"][index].isNotEmpty
                                  ? TransactionBox(
                                    name:
                                        transactionData["data"][transactionData["data"]
                                                .length -
                                            1 -
                                            index]["name"],
                                    adding:
                                        transactionData["data"][transactionData["data"]
                                                .length -
                                            1 -
                                            index]["adding"],
                                    money:
                                        transactionData["data"][transactionData["data"]
                                                    .length -
                                                1 -
                                                index]["money"]
                                            .toStringAsFixed(2),
                                  )
                                  : SizedBox(height: 0),
                        );
                      },
                    ),
                  )
                  : SizedBox(height: 500),
            ],
          ),
        ),
      ),
    );
  }

  loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //prefs.remove("moneydata");

    // Load Language & Currency (fall back to defaults)
    final savedLang = prefs.getString('language');
    if (savedLang != null && languageCodes.contains(savedLang)) {
      currentLanguage = savedLang;
      languageNotifier.value = savedLang;
    } else {
      languageNotifier.value = currentLanguage;
    }
    final savedCur = prefs.getString('currency');
    if (savedCur != null && supportedCurrencies.contains(savedCur)) {
      currentCurrency = savedCur;
      currencyNotifier.value = savedCur;
    } else {
      currencyNotifier.value = currentCurrency;
    }

    // Get Username
    String u = prefs.getString("username") ?? "John Doe";
    setState(() {
      username = u;
    });

    // Get Money Data
    String moneyDataString = prefs.getString("moneydata") ?? '{"data":[]}';
    Map<String, dynamic> moneyDataMap = jsonDecode(moneyDataString);

    // Normalize "money" values to double (jsonDecode can produce int)
    if (moneyDataMap["data"] is List) {
      for (final item in moneyDataMap["data"]) {
        if (item is Map && item["money"] is num) {
          item["money"] = (item["money"] as num).toDouble();
        }
      }
    }

    setState(() {
      moneyData = moneyDataMap;
    });

    // Get Total Money Owed
    if (moneyData["data"].isNotEmpty) {
      double tot = 0;
      for (int i = 0; i < moneyData["data"].length; i++) {
        final m = moneyData["data"][i]["money"];
        tot += (m is num) ? m.toDouble() : 0.0;
      }
      setState(() {
        totalOwed = tot;
      });

      String formattedTotalOwed = numberFormat.format(
        double.parse(totalOwed.toStringAsFixed(2)),
      );
      final moneySplit = formattedTotalOwed.split(',');
      if (moneySplit.length == 2) {
        setState(() {
          totalOwedInt = moneySplit[0];
          totalOwedDec = moneySplit[1];
        });
      } else {
        setState(() {
          totalOwedInt = moneySplit[0];
          totalOwedDec = "00";
        });
      }
    } else {
      setState(() {
        totalOwedInt = "0";
        totalOwedDec = "00";
      });
    }

    // Get Transaction Data
    String transactionDataString =
        prefs.getString("transactiondata") ?? '{"data":[]}';
    Map<String, dynamic> transactionDataMap = jsonDecode(transactionDataString);

    // Normalize "money" values to double for transactions too
    if (transactionDataMap["data"] is List) {
      for (final item in transactionDataMap["data"]) {
        if (item is Map && item["money"] is num) {
          item["money"] = (item["money"] as num).toDouble();
        }
      }
    }

    setState(() {
      transactionData = transactionDataMap;
    });
  }

  editUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final newUsername = usernameTextEditingController.text;
    await prefs.setString("username", newUsername);

    setState(() {
      username = newUsername;
      editingUsername = false;
    });

    // Persist username to Firebase when logged in
    if (userID != null && userID!.isNotEmpty) {
      try {
        final fs = FirebaseServices();
        final latestMoneyStr = prefs.getString("moneydata") ?? '{"data":[]}';
        final latestTxStr = prefs.getString("transactiondata") ?? '{"data":[]}';
        Map<String, dynamic>? m;
        Map<String, dynamic>? t;
        try {
          m = jsonDecode(latestMoneyStr) as Map<String, dynamic>;
        } catch (_) {}
        try {
          t = jsonDecode(latestTxStr) as Map<String, dynamic>;
        } catch (_) {}
        await fs.saveIOUData(
          username: newUsername,
          moneyData: m,
          transactionData: t,
        );
      } catch (_) {}
    }
  }
}
