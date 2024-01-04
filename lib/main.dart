import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:new_qasas/custom_code/actions/player_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initFirebase();

  // Start initial custom actions code
  await actions.changeStatusBarColor();
  await actions.fixDeviceOrientationUp();
  await actions.initAudioService();
  // End initial custom actions code

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appState),
        Provider<PlayerBloc>(
          create: (context) => PlayerBloc(
            musicUrls: [
              'https://firebasestorage.googleapis.com/v0/b/music-player-93920.appspot.com/o/users%2Fmusic_audio%2Funlock-me-149058.mp3?alt=media&token=831ae47e-bc26-4ca1-94e3-a68ad218a852',
              'https://firebasestorage.googleapis.com/v0/b/music-player-93920.appspot.com/o/users%2Fmusic_audio%2Frelax-hip-hop-music-for-short-vlog-videos-40-seconds-ackground-drama-155719.mp3?alt=media&token=e782f0e8-4cc4-4d46-983f-5c068faf830b',
              'https://firebasestorage.googleapis.com/v0/b/music-player-93920.appspot.com/o/users%2Fmusic_audio%2Fpowerful-beat-121791.mp3?alt=media&token=00f3ebb4-0b88-4d9e-8ac1-fbffef5c1f0c',
            ],
            titles: [
              'test track 1',
              'test track 2',
              'test track 3',
            ],
            initialUrl:
                'https://firebasestorage.googleapis.com/v0/b/music-player-93920.appspot.com/o/users%2Fmusic_audio%2Frelax-hip-hop-music-for-short-vlog-videos-40-seconds-ackground-drama-155719.mp3?alt=media&token=e782f0e8-4cc4-4d46-983f-5c068faf830b',
            playlistImage:
                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/new-qasas-f219mx/assets/3tgx6hyivp6h/NEW2_LOGO-PWA-512-Noa.png',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  late Stream<BaseAuthUser> userStream;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = newQasasFirebaseUserStream()
      ..listen((user) => _appStateNotifier.update(user));
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEW QASAS',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: const ScrollbarThemeData(),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
