import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewEventsScreen extends StatelessWidget {
  const ViewEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Events")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('status', isEqualTo: 'active')
            .orderBy('dateTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events found"));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final date = (event['dateTime'] as Timestamp).toDate();
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: ListTile(
                  title: Text(event['eventName']),
                  subtitle: Text(
                    "${event['sport']} • ${DateFormat.yMMMd().add_jm().format(date)}\nLocation: ${event['location']}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(eventId: event.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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

    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: eventsRef.doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Event not found"));
          }

          final event = snapshot.data!;
          final date = (event['dateTime'] as Timestamp).toDate();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['eventName'],
                    style:
                        const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Sport: ${event['sport']}"),
                Text("Location: ${event['location']}"),
                Text("Date: ${DateFormat.yMMMd().add_jm().format(date)}"),
                Text("Max Players: ${event['maxPlayers']}"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _joinEvent(context, eventId),
                  child: const Text("Join Event"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _joinEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance.collection('events').doc(eventId);

    await doc.update({
      'participants': FieldValue.arrayUnion([user.uid]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Joined event successfully ✅")),
    );
  }
}
