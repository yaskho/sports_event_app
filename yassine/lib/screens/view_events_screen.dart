import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewEventsScreen extends StatelessWidget {
  const ViewEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No events found",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final myId = currentUser?.uid;
            final allEvents = snapshot.data!.docs;

            final joinedEvents = allEvents
                .where((event) =>
                    List<String>.from(event['participants'] ?? [])
                        .contains(myId))
                .toList();

            final otherEvents = allEvents
                .where((event) =>
                    !List<String>.from(event['participants'] ?? [])
                        .contains(myId))
                .toList();

            final sortedEvents = [...joinedEvents, ...otherEvents];

            return ListView.builder(
              padding: const EdgeInsets.only(top: 90, bottom: 24),
              itemCount: sortedEvents.length,
              itemBuilder: (context, index) {
                final event = sortedEvents[index];
                final date = (event['dateTime'] as Timestamp).toDate();
                final hasJoined = myId != null &&
                    List<String>.from(event['participants'] ?? [])
                        .contains(myId);

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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: hasJoined
                        ? const Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 26)
                        : const Icon(Icons.sports_soccer,
                            color: Colors.white70, size: 26),
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
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 14),
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
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
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
                        child: Column(
                          children: [
                            if (isOrganizer) ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.person_add,
                                    color: Colors.white),
                                label: const Text("Add Player",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () =>
                                    _addManualPlayer(context, eventId, maxPlayers),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.person_remove,
                                    color: Colors.white),
                                label: const Text("Remove Player",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () =>
                                    _removeManualPlayer(context, eventId),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                label: const Text("Delete Event",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () => _deleteEvent(context, eventId),
                              ),
                            ] else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasJoined
                                      ? Colors.redAccent
                                      : Colors.white,
                                  foregroundColor: hasJoined
                                      ? Colors.white
                                      : const Color(0xFF2A5298),
                                  minimumSize: const Size(double.infinity, 50),
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
                          ],
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

    final eventDoc =
        await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    final data = eventDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final maxPlayers = data['maxPlayers'] ?? 0;

    if (participants.length >= maxPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ This event is already full!")),
      );
      return;
    }

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
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
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

  Future<void> _addManualPlayer(
      BuildContext context, String eventId, int maxPlayers) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    final doc = await eventRef.get();
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);

    if (participants.length >= maxPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Cannot add player — event is full")),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Player"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Player name",
            hintText: "Enter player name",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Add")),
        ],
      ),
    );

    if (shouldAdd == true && nameController.text.trim().isNotEmpty) {
      await eventRef.update({
        'participants': FieldValue.arrayUnion([nameController.text.trim()]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Player '${nameController.text}' added ✅")),
      );
    }
  }

  /// ✅ FIXED OVERFLOW ISSUE HERE
  Future<void> _removeManualPlayer(BuildContext context, String eventId) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    final doc = await eventRef.get();
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No players to remove")),
      );
      return;
    }

    String? selected;

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Player"),
        content: SizedBox(
          width: double.maxFinite,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: selected,
            items: participants
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => selected = val,
            decoration: const InputDecoration(labelText: "Select player"),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Remove")),
        ],
      ),
    );

    if (shouldRemove == true && selected != null) {
      await eventRef.update({
        'participants': FieldValue.arrayRemove([selected]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Player '$selected' removed ✅")),
      );
    }
  }
}
