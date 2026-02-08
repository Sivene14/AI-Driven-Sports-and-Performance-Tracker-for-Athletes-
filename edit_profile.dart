import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? athleteData;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? gender;
  String? sport;
  String? experienceLevel;

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> sports = [
    "Football",
    "Basketball",
    "Volleyball",
    "Athletics",
    "Swimming",
    "Tennis",
    "Cricket",
    "Rugby"
  ];
  final List<String> experienceLevels = [
    "Beginner",
    "Intermediate",
    "Advanced",
    "Professional"
  ];

  Future<void> _fetchData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('athletes').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        athleteData = data;
        nameController.text = data["name"] ?? "";
        dobController.text = data["dob"] ?? "";
        heightController.text = data["height"]?.toString() ?? "";
        weightController.text = data["weight"]?.toString() ?? "";
        gender = data["gender"];
        sport = data["sport"];
        experienceLevel = data["experienceLevel"];
      });
    }
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updatedData = {
      "name": nameController.text.trim(),
      "dob": dobController.text.trim(),
      "gender": gender,
      "height": heightController.text.trim(),
      "weight": weightController.text.trim(),
      "sport": sport,
      "experienceLevel": experienceLevel,
    };

    await FirebaseFirestore.instance.collection('athletes').doc(uid).update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: athleteData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildTextField(nameController, "Name", Icons.person, theme),
                  _buildDateField(context, theme),
                  _buildDropdown(
                    label: "Gender",
                    value: gender,
                    icon: Icons.wc,
                    items: genders,
                    onChanged: (val) => setState(() => gender = val),
                    theme: theme,
                  ),
                  _buildTextField(heightController, "Height (cm)", Icons.height, theme),
                  _buildTextField(weightController, "Weight (kg)", Icons.monitor_weight, theme),
                  _buildDropdown(
                    label: "Sport",
                    value: sport,
                    icon: Icons.sports,
                    items: sports,
                    onChanged: (val) => setState(() => sport = val),
                    theme: theme,
                  ),
                  _buildDropdown(
                    label: "Experience Level",
                    value: experienceLevel,
                    icon: Icons.star,
                    items: experienceLevels,
                    onChanged: (val) => setState(() => experienceLevel = val),
                    theme: theme,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveProfile,
              label: const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: TextField(
          controller: controller,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.cake, color: Colors.blueAccent),
        title: TextField(
          controller: dobController,
          readOnly: true,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: "Date of Birth",
            border: InputBorder.none,
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required ThemeData theme,
  }) {
    List<String> dropdownItems = List.from(items);
    if (value != null && !dropdownItems.contains(value)) {
      dropdownItems.add(value);
    }

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          items: dropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

}
