import 'package:flutter/material.dart';
import 'package:yassine_project/screens/create_event_screen.dart';
import 'package:yassine_project/screens/profile_screen.dart';
import 'package:yassine_project/screens/view_events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF2196F3); 

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Manage your events easily",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 40),

            
            _buildActionButton(
              context,
              title: "Create Event",
              icon: Icons.add_circle_outline,
              color: accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateEventScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _buildActionButton(
              context,
              title: "View Events",
              icon: Icons.event_note_outlined,
              color: accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewEventsScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _buildActionButton(
              context,
              title: "Profile",
              icon: Icons.person_outline,
              color: accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            const Spacer(),

            
            Text(
              "MatchApp",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
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
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
