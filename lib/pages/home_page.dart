import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    String? username = authProvider.username;

    Future<void> handleLogout() async {
      final confirmLogout = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Confirmation'),
              content: Text('Voulez-vous vraiment vous déconnecter?'),
              actions: [
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Déconnecter',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
      );

      if (confirmLogout == true && context.mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        try {
          // This will now wait for the 2-second delay inside logout()
          await Provider.of<AuthProvider>(context, listen: false).logout();
        } finally {
          // Dismiss loading indicator
          if (context.mounted) {
            Navigator.of(context).pop();
            // Navigate to login
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour, $username!"),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                handleLogout();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200, // Largeur fixe pour les boutons
              child: ElevatedButton(
                onPressed: () {
                  // Ajouter la logique pour "Pointer"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .lightGreen, // Couleur verte pour le bouton "Pointer"
                ),
                child: Text(
                  "Pointer",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20), // Espacement entre les deux boutons
            SizedBox(
              width: 200, // Assurez-vous que le second bouton a la même largeur
              child: ElevatedButton(
                onPressed: () {
                  // Ajouter la logique pour "Historique de présence"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .grey[300], // Couleur gris clair pour le bouton "Historique"
                ),
                child: Text(
                  "Historique de présence",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
