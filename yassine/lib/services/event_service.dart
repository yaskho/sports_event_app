import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('events');

  // 🔹 Create event
  Future<void> createEvent({
    required String sport,
    required String organizerId,
    required DateTime dateTime,
    required String location,
    required int maxPlayers,
  }) async {
    try {
      await eventsRef.add({
        'sport': sport,
        'organizerId': organizerId,
        'dateTime': Timestamp.fromDate(dateTime),
        'location': location,
        'maxPlayers': maxPlayers,
        'participants': [],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to create event: $e");
    }
  }

  // 🔹 Read (get active events)
  Stream<QuerySnapshot> getActiveEvents() {
    return eventsRef
        .where('status', isEqualTo: 'active')
        .orderBy('dateTime')
        .snapshots();
  }

  // 🔹 Join event (atomic check + join using a transaction)
  // Returns: "joined_success", "event_full", "already_joined", "event_not_found", "error"
  Future<String> joinEvent(String eventId, String userId) async {
    final docRef = eventsRef.doc(eventId);

    try {
      final result = await _firestore.runTransaction<String>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          return "event_not_found";
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final List<dynamic> rawParticipants = data['participants'] ?? [];
        final participants = rawParticipants.cast<String>().toList();
        final maxPlayers = (data['maxPlayers'] is int)
            ? data['maxPlayers'] as int
            : int.tryParse(data['maxPlayers']?.toString() ?? '0') ?? 0;

        // Already joined
        if (participants.contains(userId)) {
          return "already_joined";
        }

        // Full?
        if (participants.length >= maxPlayers) {
          return "event_full";
        }

        // Add user atomically: compute new list and write it
        final updatedParticipants = List<String>.from(participants)..add(userId);
        transaction.update(docRef, {'participants': updatedParticipants});

        return "joined_success";
      });

      return result;
    } catch (e) {
      // You may want to log e in production
      return "error";
    }
  }

  // 🔹 Quit event
  Future<void> quitEvent(String eventId, String userId) async {
    try {
      // Using arrayRemove is fine here (not strictly transactional)
      await eventsRef.doc(eventId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception("Failed to quit event: $e");
    }
  }

  // 🔹 Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await eventsRef.doc(eventId).delete();
    } catch (e) {
      throw Exception("Failed to delete event: $e");
    }
  }
}
