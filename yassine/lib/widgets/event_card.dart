import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String sport;
  final String location;
  final String date;
  final int playersNeeded;

  const EventCard({
    super.key,
    required this.sport,
    required this.location,
    required this.date,
    required this.playersNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('$sport Match', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('📍 $location\n🕒 $date'),
        trailing: Text(
          '$playersNeeded missing',
          style: const TextStyle(color: Colors.redAccent),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/event-details');
        },
      ),
    );
  }
}
