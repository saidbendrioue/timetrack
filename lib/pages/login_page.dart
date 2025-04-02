import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetrack/models/employe.model.dart';
import 'package:timetrack/providers/auth_provider.dart';
import 'package:timetrack/services/login_service.dart';
import 'home_Page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController _emailController = TextEditingController(
    text: "jean.dupont@example.com",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "password123",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // First part - Logo
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset("assets/truck_logo.png", height: 100),
              ),
            ),

            // Second part - Email Field
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Third part - Password Field
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Fourth part - Login Button
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => handleLogin(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Text("Se connecter"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final loginService = LoginService();
      final response = await loginService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response["status"] == "success") {
        final employe = Employe.fromJson(response["employe"]);
        await authProvider.login(employe);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }
    }
  }
}
