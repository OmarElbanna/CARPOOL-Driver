import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Account.dart';
import 'Home.dart';
import 'Login.dart';
import 'MyTrips.dart';
import 'Signup.dart';
import 'Splash.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff9fc9ff),
          primaryContainer: Color(0xff00325b),
          secondary: Color(0xffffb59d),
          secondaryContainer: Color(0xff872100),
          tertiary: Color(0xff86d2e1),
          tertiaryContainer: Color(0xff004e59),
          appBarColor: Color(0xff872100),
          error: Color(0xfff6385b),
        ),
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 18,
        appBarStyle: FlexAppBarStyle.background,
        bottomAppBarElevation: 2.0,
        darkIsTrueBlack: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          drawerBackgroundSchemeColor: SchemeColor.onTertiary,
          elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
          elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
          segmentedButtonSchemeColor: SchemeColor.primary,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorBackgroundAlpha: 43,
          inputDecoratorRadius: 8.0,
          inputDecoratorUnfocusedHasBorder: false,
          inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
          fabSchemeColor: SchemeColor.tertiary,
          popupMenuRadius: 6.0,
          popupMenuElevation: 4.0,
          alignedDropdown: true,
          dialogElevation: 3.0,
          dialogRadius: 20.0,
          useInputDecoratorThemeInDialogs: true,
          snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
          drawerIndicatorSchemeColor: SchemeColor.primary,
          bottomSheetRadius: 20.0,
          bottomSheetElevation: 2.0,
          bottomSheetModalElevation: 3.0,
          bottomNavigationBarMutedUnselectedLabel: false,
          bottomNavigationBarMutedUnselectedIcon: false,
          bottomNavigationBarBackgroundSchemeColor: SchemeColor.surfaceVariant,
          menuRadius: 6.0,
          menuElevation: 4.0,
          menuBarRadius: 0.0,
          menuBarElevation: 1.0,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarMutedUnselectedLabel: false,
          navigationBarSelectedIconSchemeColor: SchemeColor.background,
          navigationBarMutedUnselectedIcon: false,
          navigationBarIndicatorSchemeColor: SchemeColor.primary,
          navigationBarIndicatorOpacity: 1.00,
          navigationBarBackgroundSchemeColor: SchemeColor.background,
          navigationBarElevation: 1.0,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailMutedUnselectedLabel: false,
          navigationRailSelectedIconSchemeColor: SchemeColor.background,
          navigationRailMutedUnselectedIcon: false,
          navigationRailIndicatorSchemeColor: SchemeColor.primary,
          navigationRailIndicatorOpacity: 1.00,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup_s': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => AccountScreen(
              updateCallback: () {},
            ),
        '/mytrips': (context) => const TripsScreen(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
