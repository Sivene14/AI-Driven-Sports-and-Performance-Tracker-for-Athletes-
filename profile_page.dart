import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? athleteData;

  Future<void> _getAthleteData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('athletes').doc(uid).get();
    setState(() {
      athleteData = doc.data();
    });
  }

  @override
  void initState() {
    super.initState();
    _getAthleteData();
  }

  // Ordered fields with labels and icons
  final List<Map<String, dynamic>> fieldOrder = [
    {"key": "name", "label": "Name", "icon": Icons.person},
    {"key": "dob", "label": "Date of Birth", "icon": Icons.cake},
    {"key": "gender", "label": "Gender", "icon": Icons.wc},
    {"key": "height", "label": "Height", "icon": Icons.height},
    {"key": "weight", "label": "Weight", "icon": Icons.monitor_weight},
    {"key": "sport", "label": "Sport", "icon": Icons.sports},
    {"key": "experienceLevel", "label": "Experience Level", "icon": Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ adapts to dark/light theme
      appBar: AppBar(
        title: const Text("Athlete Profile"),
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.blueAccent,
        centerTitle: true,
        elevation: 2,
      ),
      body: athleteData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: fieldOrder.map((field) {
                        final key = field["key"] as String;
                        final label = field["label"] as String;
                        final icon = field["icon"] as IconData;

                        if (!athleteData!.containsKey(key)) return const SizedBox.shrink();

                        return Card(
                          color: theme.cardColor, // ✅ adapts to dark/light theme
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(icon, color: Colors.blueAccent), // keep blue accent
                            title: Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              athleteData![key].toString(),
                              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // ✅ fixed blue button
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfilePage()),
                        ).then((_) {
                          _getAthleteData(); // Refresh after editing
                        });
                      },
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ white text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}