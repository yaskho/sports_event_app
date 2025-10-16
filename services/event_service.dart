class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createEvent(EventModel event) async {
    await _db.collection('events').doc(event.eventId).set(event.toMap());
  }

  Stream<List<EventModel>> getEvents() {
    return _db.collection('events').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList()
    );
  }

  Future<void> joinEvent(String eventId, String userId) async {
    DocumentReference doc = _db.collection('events').doc(eventId);
    await doc.update({
      'participants': FieldValue.arrayUnion([userId])
    });
  }
}
