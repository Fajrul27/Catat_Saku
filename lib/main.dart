import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';
import 'models/transaction.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/edit_transaction_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'pages/transaction_detail_page.dart';
import 'pages/about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
  runApp(MyApp(hasSeenWelcome: hasSeenWelcome));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.hasSeenWelcome});

  final bool hasSeenWelcome;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _hasSeenWelcome;

  @override
  void initState() {
    super.initState();
    _hasSeenWelcome = widget.hasSeenWelcome;
  }

  void markWelcomeSeen() {
    if (_hasSeenWelcome) return;
    setState(() {
      _hasSeenWelcome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Catat Saku',
            debugShowCheckedModeBanner: false,
            locale: const Locale('id', 'ID'),
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.effectiveThemeMode,
            initialRoute: _hasSeenWelcome ? '/home' : '/',
            routes: {
              '/': (context) => const WelcomePage(),
              '/home': (context) => const HomePage(),
              '/add-transaction': (context) => const AddTransactionPage(),
              '/history': (context) => const HistoryPage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/transaction-detail') {
                final transaction = settings.arguments as Transaction;
                return MaterialPageRoute(
                  builder: (context) => TransactionDetailPage(transaction: transaction),
                );
              }
              if (settings.name == '/edit-transaction') {
                final transaction = settings.arguments as Transaction;
                return MaterialPageRoute(
                  builder: (context) => EditTransactionPage(transaction: transaction),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
