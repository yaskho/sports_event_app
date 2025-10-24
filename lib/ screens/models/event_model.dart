class EventModel {
  String eventId;
  String organizerId;
  String sport;
  DateTime dateTime;
  String location;
  List<String> participants;
  int maxPlayers;
  String status;

  EventModel({required this.eventId, required this.organizerId, required this.sport,
    required this.dateTime, required this.location, required this.participants,
    required this.maxPlayers, required this.status});

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'organizerId': organizerId,
    'sport': sport,
    'dateTime': dateTime,
    'location': location,
    'participants': participants,
    'maxPlayers': maxPlayers,
    'status': status,
  };

  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
    eventId: map['eventId'],
    organizerId: map['organizerId'],
    sport: map['sport'],
    dateTime: (map['dateTime'] as Timestamp).toDate(),
    location: map['location'],
    participants: List<String>.from(map['participants']),
    maxPlayers: map['maxPlayers'],
    status: map['status'],
  );
}
