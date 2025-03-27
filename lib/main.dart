import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetrack/pages/historique_page.dart';
import 'package:timetrack/pages/home_page.dart';
import 'package:timetrack/pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => AuthProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/', // This will be your initial route
      routes: {
        '/': (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          // Check if user is authenticated
          return authProvider.isAuth ? HomePage() : LoginPage();
        },
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/historique': (context) => const HistoriquePage(),
      },
    );
  }
}
