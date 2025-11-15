import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection('events');

  
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

  
  Stream<QuerySnapshot> getActiveEvents() {
    return eventsRef
        .where('status', isEqualTo: 'active')
        .orderBy('dateTime')
        .snapshots();
  }

  
  
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

        
        if (participants.contains(userId)) {
          return "already_joined";
        }

        
        if (participants.length >= maxPlayers) {
          return "event_full";
        }

        
        final updatedParticipants = List<String>.from(participants)..add(userId);
        transaction.update(docRef, {'participants': updatedParticipants});

        return "joined_success";
      });

      return result;
    } catch (e) {
      
      return "error";
    }
  }

  
  Future<void> quitEvent(String eventId, String userId) async {
    try {
      
      await eventsRef.doc(eventId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception("Failed to quit event: $e");
    }
  }

  
  Future<void> deleteEvent(String eventId) async {
    try {
      await eventsRef.doc(eventId).delete();
    } catch (e) {
      throw Exception("Failed to delete event: $e");
    }
  }
}
