import 'utils/platform_imports.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Accepts self-signed certificates in development/Docker builds.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // Allow self-signed HTTPS in debug mode OR when built with ALLOW_SELF_SIGNED=true.
  const allowSelfSigned = bool.fromEnvironment('ALLOW_SELF_SIGNED', defaultValue: false);
  if (kDebugMode || allowSelfSigned) {
    HttpOverrides.global = _DevHttpOverrides();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const GreffeRenaleApp(),
    ),
  );
}

class GreffeRenaleApp extends StatefulWidget {
  const GreffeRenaleApp({super.key});

  @override
  State<GreffeRenaleApp> createState() => _GreffeRenaleAppState();
}

class _GreffeRenaleAppState extends State<GreffeRenaleApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthService>().tryAutoLogin();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return MaterialApp(
      title: 'Greffe Rénale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr')],
      locale: const Locale('fr'),
      home: !_initialized
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : auth.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
