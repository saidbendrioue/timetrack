import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_Page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();

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

            // Second part - Text Field
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Nom d'utilisateur",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Third part - Login Button
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

  handleLogin(BuildContext context) async {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
    }
    await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).login(_controller.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
