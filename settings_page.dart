import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'edit_profile.dart';
import 'theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _deleteProfileConfirmed(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      await FirebaseFirestore.instance.collection('athletes').doc(uid).delete();
      await user.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _deleteProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text(
          "All your data will be permanently deleted.\n\n"
          "Are you sure you want to delete your profile?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              _deleteProfileConfirmed(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: const Text("Edit Profile"),
                  subtitle: const Text("Update your personal information"),
                  onTap: () => _editProfile(context),
                ),
                const Divider(),

                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.blueAccent),
                  title: const Text("Dark Mode"),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Logout"),
                  onTap: () => _logout(context),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Delete Profile"),
                  subtitle: const Text("This action cannot be undone"),
                  onTap: () => _deleteProfile(context), // ✅ now shows popup
                ),
              ],
            ),
          ),

          // Footer About Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Sports Tracker v1.0\n© 2026 Sivene Spv",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}