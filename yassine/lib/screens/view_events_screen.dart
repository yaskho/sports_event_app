import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewEventsScreen extends StatelessWidget {
  const ViewEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("All Events"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('status', isEqualTo: 'active')
              .orderBy('dateTime')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No events found",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              );
            }

            final events = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 90, bottom: 24),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final date = (event['dateTime'] as Timestamp).toDate();
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      event['eventName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "${event['sport']} • ${DateFormat.yMMMd().add_jm().format(date)}\n📍 ${event['location']}",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailScreen(eventId: event.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    final eventsRef = FirebaseFirestore.instance.collection('events');
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          "Event Details",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: eventsRef.doc(eventId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text("Event not found",
                      style: TextStyle(color: Colors.white70)),
                );
              }

              final event = snapshot.data!;
              final date = (event['dateTime'] as Timestamp).toDate();
              final participants =
                  List<String>.from(event['participants'] ?? []);
              final maxPlayers = event['maxPlayers'] ?? 0;
              final missingPlayers = (maxPlayers - participants.length);
              final organizerId = event['organizerId'];
              final hasJoined = currentUser != null &&
                  participants.contains(currentUser.uid);
              final isOrganizer =
                  currentUser != null && organizerId == currentUser.uid;

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['eventName'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildDetailRow(Icons.sports_soccer, "Sport", event['sport']),
                      _buildDetailRow(Icons.place, "Location", event['location']),
                      _buildDetailRow(Icons.calendar_month, "Date",
                          DateFormat.yMMMd().add_jm().format(date)),
                      _buildDetailRow(Icons.people, "Max Players", "$maxPlayers"),
                      _buildDetailRow(Icons.person_outline, "Missing Players",
                          "$missingPlayers"),
                      const SizedBox(height: 40),
                      Center(
                        child: isOrganizer
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  minimumSize:
                                      const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                label: const Text("Delete Event",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () => _deleteEvent(context, eventId),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasJoined
                                      ? Colors.redAccent
                                      : Colors.white,
                                  foregroundColor: hasJoined
                                      ? Colors.white
                                      : const Color(0xFF2A5298),
                                  minimumSize:
                                      const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  if (hasJoined) {
                                    _quitEvent(context, eventId);
                                  } else {
                                    _joinEvent(context, eventId);
                                  }
                                },
                                child: Text(
                                  hasJoined ? "Quit Event" : "Join Event",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 10),
          Text("$label: ",
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Future<void> _joinEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({'participants': FieldValue.arrayUnion([user.uid])});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Joined event successfully ✅")),
    );
  }

  Future<void> _quitEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({'participants': FieldValue.arrayRemove([user.uid])});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You left the event ❌")),
    );
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text(
            "Are you sure you want to delete this event? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully 🗑️")),
      );
      Navigator.pop(context);
    }
  }
}
