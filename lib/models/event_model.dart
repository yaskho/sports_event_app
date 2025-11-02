import 'package:cloud_firestore/cloud_firestore.dart';
class EventModel {
  final String eventId;
  final String sport;
  final String organizerId;
  final DateTime dateTime;
  final String location;
  final int maxPlayers;
  final List<String> participants;
  final String status;
  final String? eventName; // optional, for display

  EventModel({
    required this.eventId,
    required this.sport,
    required this.organizerId,
    required this.dateTime,
    required this.location,
    required this.maxPlayers,
    required this.participants,
    required this.status,
    this.eventName,
  });

  // Convert Firestore document → EventModel
  factory EventModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EventModel(
      eventId: documentId,
      sport: data['sport'] ?? '',
      organizerId: data['organizerId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      maxPlayers: data['maxPlayers'] ?? 0,
      participants:
          List<String>.from(data['participants'] ?? []),
      status: data['status'] ?? 'active',
      eventName: data['eventName'] ?? '',
    );
  }

  // Convert EventModel → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'sport': sport,
      'organizerId': organizerId,
      'dateTime': dateTime,
      'location': location,
      'maxPlayers': maxPlayers,
      'participants': participants,
      'status': status,
      'eventName': eventName,
    };
  }
}

