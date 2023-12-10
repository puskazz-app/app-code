import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:power_file_view/power_file_view.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:puskazz_app/Pages/LoadCheat/LoadTextCheat.dart';
import 'package:puskazz_app/Pages/OnboardingScreens/PremiumShowcaseScreen.dart';
import 'package:puskazz_app/Pages/MorePages/DocumentViewerPage.dart';
import 'package:puskazz_app/Pages/MorePages/PremiumPurchased.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puskazz_app/HomePage.dart';
import 'package:flutter/foundation.dart';
import 'package:puskazz_app/Pages/Etc/NetworkConnectivityPage.dart';
import 'package:puskazz_app/Pages/Etc/PurchasePremiumPage.dart';
import 'package:puskazz_app/Pages/LoadCheat/ImageBasedPage.dart';
import 'package:puskazz_app/Pages/LoadCheat/LoadedCheatPage.dart';
import 'package:puskazz_app/Pages/LoadCheat/QRScannerPage.dart';
import 'package:puskazz_app/Pages/LoadCheat/TextBasedPage.dart';
import 'package:puskazz_app/Pages/OnboardingScreens/WelcomeScreen.dart';
import 'package:puskazz_app/Pages/MorePages/SavedCheats.dart';
import 'package:puskazz_app/Pages/MorePages/SettingsPage.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/cupertino.dart';

bool? isSettedUp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await StatusBarControl.setHidden(true);

  Wakelock.enable();

  PowerFileViewManager.initEngine();

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  isSettedUp = await prefs.getBool('isSettedUp') ?? false;

  await Firebase.initializeApp(
      name: 'puskazz_app', options: DefaultFirebaseOptions.currentPlatform);

  bool? _enableAnalytics = prefs.getBool("enableAnalytics") ?? true;

  if (_enableAnalytics == true) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } else {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puskázz App',
      debugShowCheckedModeBanner: false,
      locale: const Locale('hu', 'HU'),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('hu', 'HU'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.grey,
            selectionHandleColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.black,
          useMaterial3: true,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      darkTheme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.grey,
            selectionHandleColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.white,
          useMaterial3: true,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      initialRoute: '/',
      routes: {
        '/welcome': (context) => const OnboardingScreen(),
        '/homepage': (context) => const HomePage(),
        '/load': (context) => const LoadedCheatsPage(),
        '/loadText': (context) => const LoadTextCheat(),
        '/image': (context) => const ImageBasedPage(),
        '/text': (context) => const TextBasedPage(),
        //'/canvas': (context) => const SharedTextPage(),
        '/purchase': (context) => PurchaseScreen(),
        '/premiumPurchased': (context) => PremiumPurchased(),
        '/saved': (context) => const SavedCheats(),
        '/settings': (context) => const SettingsPage(),
        '/qr': (context) => const QRScannerPage(),
        '/premiumsShowcase': (context) => const PremiumShowcaseScreen(),
        '/thanks': (context) => const ThanksForPurchaseScreen(),
        '/errorPurchase': (context) => const ErrorPurchaseScreen(),
        '/invalidPurchase': (context) => const InvalidPremiumScreen(),
        '/cancelledPurchase': (context) => const CancelledPremiumScreen(),
        '/doc': (context) => const DocumentViewerPage(),
      },
      home: isSettedUp == true
          ? NetworkConnectivity(destination: 'homepage')
          : OnboardingScreen(),
    );
  }
}
