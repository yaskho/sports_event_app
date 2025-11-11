import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:yassine_project/screens/locatisation_screen.dart';

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
  double? _selectedLat;
  double? _selectedLng;

  final sports = ["Football", "Basketball", "Padel"];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blueAccent,
              surface: const Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              dialBackgroundColor: Colors.blueAccent.withOpacity(0.2),
              hourMinuteTextColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
        const SnackBar(content: Text("Please fill all fields")),
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
      "latitude": _selectedLat,
      "longitude": _selectedLng,
      "maxPlayers": int.parse(_maxPlayersController.text.trim()),
      "dateTime": dateTime,
      "organizerId": uid,
      "participants": [uid],
      "status": "active",
      "createdAt": DateTime.now(),
    });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event created successfully ✅")),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: icon != null ? Icon(icon, color: Colors.blueAccent) : null,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          "Create Event",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            DropdownButtonFormField<String>(
              value: _selectedSport,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              items: sports.map((sport) {
                return DropdownMenuItem(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSport = value!),
              decoration: _inputDecoration("Select Sport", icon: Icons.sports),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _eventNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Event Name", icon: Icons.title),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _locationController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Location", icon: Icons.location_on),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                );
                if (result != null) {
                  setState(() {
                    _locationController.text = result['address'];
                    _selectedLat = result['lat'];
                    _selectedLng = result['lng'];
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _maxPlayersController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Max Players", icon: Icons.group),
            ),
            const SizedBox(height: 20),

            
            ListTile(
              tileColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                _selectedDate == null
                    ? "Select Date"
                    : DateFormat.yMMMd().format(_selectedDate!),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                _selectedTime == null
                    ? "Select Time"
                    : _selectedTime!.format(context),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.access_time, color: Colors.blueAccent),
              onTap: _pickTime,
            ),

            const SizedBox(height: 30),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : ElevatedButton(
                    onPressed: _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create Event",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
