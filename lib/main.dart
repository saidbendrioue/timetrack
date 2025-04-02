import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetrack/pages/historique_page.dart';
import 'package:timetrack/pages/home_page.dart';
import 'package:timetrack/pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => authProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/',
      routes: {
        '/': (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          // Show loading indicator while checking auth state
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return authProvider.isAuth ? const HomePage() : LoginPage();
        },
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/historique': (context) => const HistoriquePage(),
      },
    );
  }
}