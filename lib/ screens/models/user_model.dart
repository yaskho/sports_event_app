class UserModel {
  String uid;
  String name;
  String email;
  List<String> preferredSports;
  List<String> joinedEvents;

  UserModel({required this.uid, required this.name, required this.email,
    required this.preferredSports, required this.joinedEvents});

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'preferredSports': preferredSports,
    'joinedEvents': joinedEvents,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    preferredSports: List<String>.from(map['preferredSports']),
    joinedEvents: List<String>.from(map['joinedEvents']),
  );
}
