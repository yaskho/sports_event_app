class EventModel {
  final String eventId;
  final String sport;
  final String organizerId;
  final DateTime dateTime;
  final String location;
  final int maxPlayers;
  final List<String> participants;
  final String status;

  EventModel({
    required this.eventId,
    required this.sport,
    required this.organizerId,
    required this.dateTime,
    required this.location,
    required this.maxPlayers,
    required this.participants,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'sport': sport,
      'organizerId': organizerId,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'maxPlayers': maxPlayers,
      'participants': participants,
      'status': status,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['eventId'],
      sport: map['sport'],
      organizerId: map['organizerId'],
      dateTime: DateTime.parse(map['dateTime']),
      location: map['location'],
      maxPlayers: map['maxPlayers'],
      participants: List<String>.from(map['participants'] ?? []),
      status: map['status'],
    );
  }
}
