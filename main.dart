import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'services/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RickMortyApp());
}

class RickMortyApp extends StatefulWidget {
  const RickMortyApp({super.key});

  @override
  State<RickMortyApp> createState() => _RickMortyAppState();
}

class _RickMortyAppState extends State<RickMortyApp> {
  String? _username;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final username = await PreferencesService().getSession();
    if (!mounted) return;
    setState(() {
      _username = username;
      _checkingSession = false;
    });
  }

  Future<void> _logout() async {
    await PreferencesService().clearSession();
    if (!mounted) return;
    setState(() => _username = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF168B83),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F7),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: _checkingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _username == null
              ? AuthScreen(
                  onAuthenticated: () async {
                    final username = await PreferencesService().getSession();
                    if (!mounted) return;
                    setState(() => _username = username);
                  },
                )
              : HomeShell(username: _username!, onLogout: _logout),
    );
  }
}
