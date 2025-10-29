import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 16),
                  Text(user.displayName ?? "Anonymous",
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user.email ?? ""),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                    child: const Text("Logout"),
                  )
                ],
              ),
            ),
    );
  }
}
