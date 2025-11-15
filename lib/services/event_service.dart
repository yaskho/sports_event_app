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

  // 🔹 Join event
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      await eventsRef.doc(eventId).update({
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception("Failed to join event: $e");
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
