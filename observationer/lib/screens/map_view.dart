import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:observationer/model/input_dialog.dart';
import 'package:observationer/model/observation.dart';
import 'package:observationer/screens/add_observation.dart';
import 'package:observationer/screens/android_input_dialog.dart';
import 'package:observationer/screens/ios_input_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observationer/util/location_manager.dart';
import 'package:observationer/util/observations_api.dart';
import 'bottom_nav_bar.dart';

/// The map view. Shows current position and allows user to create new observations.
class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //TODO: This should be loaded in from current GPS position.
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  InputDialog _inputDialog;

  LocationManager _locationManager;

  GoogleMap _googleMap;
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _cameraPosition = _kGooglePlex;

  bool _permission = false;

  /// Animates away to the users current location.
  Future<void> goToCurrentLocation(Position position) async {
    final GoogleMapController controller = await _controller.future;
    _cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.4746,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  /// Displays the GPS-coords in the bottom of the view.
  Widget currentLocationView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 45.0,
        width: 300.0,
        decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10.0)),
        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
        margin: EdgeInsets.only(bottom: 30.0),
        child: locationAvailable(),
      ),
    );
  }

  /// If location is not available this func will return appropriate UI for that.
  Widget locationAvailable() {
    return _locationManager.getPosition() == null
        ? Center(
            child: Text(
              'Location unavailable',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lat:${_locationManager.getPosition().latitude.toString()}',
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
              SizedBox(
                width: 16.0,
              ),
              Text(
                'Long:${_locationManager.getPosition().longitude.toString()}',
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ],
          );
  }

  @override
  void dispose() {
    super.dispose();
    _locationManager.stopPositionUpdates();
  }

  @override
  void initState() {
    super.initState();
  }

  void supplyDialog() {
    // Platform.isIOS
    //     ? _inputDialog = iOSInputDialog(
    //         onPressPositive: uploadObservation,
    //         onPressNegative: () {},
    //         pos: _locationManager.getPosition())
    //     : _inputDialog = AndroidInputDialog(
    //         onPressPositive: uploadObservation,
    //         onPressNegative: () {},
    //         pos: _locationManager.getPosition());
  }

  void uploadObservation(Observation observation) {
    if (observation.subject == null ||
        observation.latitude == null ||
        observation.longitude == null)
      return; // TODO: Probably present an error message or something.

    ObservationsAPI.uploadObservation(
        title: observation.subject,
        description: observation.body,
        latitude: observation.latitude,
        longitude: observation.longitude);
  }

  Future<void> initView() async {
    _locationManager = LocationManager();

    _permission = await _locationManager.checkPermission();

    if (_permission) {
      _initMapAndLocationRequests();
    } else {
      bool request = await _locationManager.requestPermission();
      if (request) {
        _initMapAndLocationRequests();
      } else {
        _permission = false;
      }
    }
  }

  Future<void> _initMapAndLocationRequests() async {
    _googleMap = GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.hybrid,
      liteModeEnabled: false,
      initialCameraPosition: _kGooglePlex,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );

    _locationManager.onLocationServicesDisabled(() {
      setState(() {}); // redraw
    });

    _locationManager.onLocationServicesEnabled(() {
      setState(() {}); // redraw
    });

    Position p = await _locationManager.getCurrentLocation();

    goToCurrentLocation(p);
    setState(() {});

    _locationManager.getPositionUpdates((lat, long) {
      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(lat, long),
          zoom: 14.4746,
        );
      });
    });
  }

  Widget locationNotAllowedView() {
    return Container(
      child: Center(
        child: Text(
          'If you have not, please allow access to your location to use this view.',
          style: TextStyle(fontSize: 22.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permission) initView();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'icon',
              child: Image(
                color: Colors.white,
                image: AssetImage('assets/images/obs_icon.png'),
                width: 20.0,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text('Karta'),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            _googleMap == null ? locationNotAllowedView() : _googleMap,
            currentLocationView(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            _FaddObservation();
          },
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: navbar(0),
    );
  }

  _FaddObservation() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddObservation(_locationManager.getPosition())),
    );
  }
}
