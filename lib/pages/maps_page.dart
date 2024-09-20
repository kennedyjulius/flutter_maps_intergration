import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  Location _locationController = new Location();
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentp = null;

  @override
  void initState() {
    super.initState();
    getLocationUpdate();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: _currentp == null ? const Center(
          child: Text("Loading .."),
        )
        :GoogleMap(
          onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
          initialCameraPosition: CameraPosition(
          target: _pGooglePlex,
          zoom: 13.0,
          ),
          markers: {
          Marker(
            markerId: MarkerId("_sourceLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pGooglePlex,
            
            ),

            Marker(
            markerId: MarkerId("_destinationLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pApplePark,
            
            ),

             Marker(
            markerId: MarkerId("_currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _currentp!,
            
            ),

            
          },
          ),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async{
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosistion = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosistion));
  }

  Future<void> getLocationUpdate() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
    _serviceEnabled = await _locationController.requestService();
    } else{
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await _locationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
    return;
    }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocatipon){
      if (currentLocatipon.latitude !=null && currentLocatipon.longitude != null) {
      setState(() {
        _currentp = LatLng(currentLocatipon.latitude!, currentLocatipon.longitude!);
        _cameraToPosition(_currentp!);
      });
      }
    });

    Future<List<LatLng>> getPolylinePoints() async{
      List<LatLng> polylineCoordinates = [];
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(request: request);
    }
  }
}