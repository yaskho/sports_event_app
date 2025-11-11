import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _pickedLocation = const LatLng(36.8663, 10.1647); 
  String? _pickedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _pickedLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);
    final placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    final place = placemarks.first;
    setState(() {
      _pickedAddress =
          "${place.street}, ${place.locality}, ${place.country}";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location")),
      body: _pickedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pickedLocation!,
                    zoom: 16,
                  ),
                  onMapCreated: (c) => _controller = c,
                  onTap: (pos) {
                    setState(() => _pickedLocation = pos);
                    _getAddressFromLatLng(pos);
                  },
                  markers: _pickedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId("picked"),
                            position: _pickedLocation!,
                          ),
                        },
                ),
                if (_pickedAddress != null)
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                      ),
                      child: Text(
                        _pickedAddress!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _pickedLocation == null
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'lat': _pickedLocation!.latitude,
                              'lng': _pickedLocation!.longitude,
                              'address': _pickedAddress ?? 'Unknown location',
                            });
                          },
                    child: const Text("Confirm Location"),
                  ),
                )
              ],
            ),
    );
  }
}
