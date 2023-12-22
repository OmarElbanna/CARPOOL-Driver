import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinLocationScreen extends StatefulWidget {
  const PinLocationScreen({super.key});

  @override
  State<PinLocationScreen> createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  LatLng? selectedLocation;
  List<Marker> myMarker = [];
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Select Location on Map',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        markers: Set.from(myMarker),
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.06463470271536, 31.278822840356383),
          zoom: 12.0,
        ),
        onTap: (LatLng latLng) {
          setState(() {
            myMarker = [];
            selectedLocation = latLng;
            myMarker.add(Marker(
                markerId: MarkerId(latLng.toString()), position: latLng));
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
