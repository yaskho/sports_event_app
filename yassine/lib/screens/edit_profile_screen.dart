import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yassine_project/models/user_model.dart';
import 'package:yassine_project/screens/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController(); 
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.displayName ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _reauthenticateUser(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = _nameController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    bool nameUpdated = false;
    bool passwordUpdated = false;

    try {
      
      if (newPassword.isNotEmpty) {
        if (currentPassword.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ Enter your CURRENT password to change it."),
            ),
          );
          return;
        }

        final ok = await _reauthenticateUser(currentPassword);
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Current password is incorrect."),
            ),
          );
          return;
        }

        await user.updatePassword(newPassword);
        passwordUpdated = true;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      }

      
      if (newName != user.displayName) {
        await user.updateDisplayName(newName);
        nameUpdated = true;
      }

      if (!nameUpdated && !passwordUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No changes detected.")),
        );
        return;
      }

      
      final updatedUser = UserModel(
        userId: user.uid,
        name: newName,
        email: user.email!,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 30),

              
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Full Name", Icons.person),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter your name" : null,
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _inputDecoration("Current Password (required to change password)", Icons.lock),
              ),

              const SizedBox(height: 20),

              
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _inputDecoration("New Password (leave empty to keep old)", Icons.lock_outline),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return "Password must be at least 6 characters.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
