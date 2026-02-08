import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _dob;
  String? _selectedSport;
  String? _selectedExperience;
  String? _selectedGender;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ✅ Match EditProfilePage lists
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
  final List<String> genders = ["Male", "Female", "Other"];

  Future<void> _registerAthlete() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;

      await FirebaseFirestore.instance.collection('athletes').doc(uid).set({
        "name": _nameController.text.trim(),
        "dob": _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year}" : "",
        "gender": _selectedGender ?? "",
        "sport": _selectedSport ?? "",
        "experienceLevel": _selectedExperience ?? "", // ✅ matches EditProfilePage
        "height": _heightController.text.trim(),
        "weight": _weightController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dob = picked;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Date of Birth
              InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                  ),
                  child: Text(
                    _dob != null
                        ? "${_dob!.day}/${_dob!.month}/${_dob!.year}"
                        : "Select your DOB",
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: genders.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                decoration: const InputDecoration(
                  labelText: "Gender",
                  prefixIcon: Icon(Icons.people, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Sport dropdown
              DropdownButtonFormField<String>(
                value: _selectedSport,
                items: sports.map((sport) {
                  return DropdownMenuItem(value: sport, child: Text(sport));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSport = val),
                decoration: const InputDecoration(
                  labelText: "Sport",
                  prefixIcon: Icon(Icons.sports, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Experience dropdown
              DropdownButtonFormField<String>(
                value: _selectedExperience,
                items: experienceLevels.map((exp) {
                  return DropdownMenuItem(value: exp, child: Text(exp));
                }).toList(),
                onChanged: (val) => setState(() => _selectedExperience = val),
                decoration: const InputDecoration(
                  labelText: "Experience Level",
                  prefixIcon: Icon(Icons.star, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Height
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  prefixIcon: Icon(Icons.height, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  prefixIcon: Icon(Icons.monitor_weight, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                ),
              ),

              const SizedBox(height: 12),
              // Password with toggle
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Confirm Password with toggle
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _registerAthlete,
                  label: const Text(
                    "Register",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}