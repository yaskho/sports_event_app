import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yassine_project/screens/edit_profile_screen.dart';
import 'package:yassine_project/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final accent = const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Text(
                "No user logged in",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.9),
                          accent.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFF1A1D23),
                      child: Icon(Icons.person, color: Colors.white70, size: 50),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  Text(
                    user.displayName ?? "Anonymous User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.email ?? "No email provided",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
                  const SizedBox(height: 30),

                  
                  _buildProfileButton(
                    context: context,
                    icon: Icons.edit_outlined,
                    label: "Edit Profile",
                    color: accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: user),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileButton(
                    context: context,
                    icon: Icons.logout,
                    label: "Logout",
                    color: Colors.redAccent,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),

                  const Spacer(),

                  
                  Text(
                    "MatchApp",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
