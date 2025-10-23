import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  String _selectedSport = "Football";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final sports = ["Football", "Basketball", "Tennis", "Volleyball", "Running"];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _createEvent() async {
    if (_eventNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _maxPlayersController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection("events").add({
      "sport": _selectedSport,
      "eventName": _eventNameController.text.trim(),
      "location": _locationController.text.trim(),
      "maxPlayers": int.parse(_maxPlayersController.text.trim()),
      "dateTime": dateTime,
      "organizerId": uid,
      "participants": [],
      "status": "active",
      "createdAt": DateTime.now(),
    });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event created successfully ✅")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Create Event",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),

                    // Sport dropdown
                    DropdownButtonFormField(
                      value: _selectedSport,
                      items: sports.map((sport) {
                        return DropdownMenuItem(value: sport, child: Text(sport));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSport = value!),
                      decoration: InputDecoration(labelText: "Select Sport"),
                    ),

                    TextField(
                      controller: _eventNameController,
                      decoration: InputDecoration(labelText: "Event Name"),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: "Location"),
                    ),
                    TextField(
                      controller: _maxPlayersController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Max Players"),
                    ),

                    SizedBox(height: 12),

                    // Date Picker
                    ListTile(
                      title: Text(_selectedDate == null
                          ? "Select Date"
                          : DateFormat.yMMMd().format(_selectedDate!)),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),

                    // Time Picker
                    ListTile(
                      title: Text(_selectedTime == null
                          ? "Select Time"
                          : _selectedTime!.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: _pickTime,
                    ),

                    SizedBox(height: 20),

                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _createEvent,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text("Create Event"),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
