import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:weather/weather.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MapWidget(),
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  LocationData? _currentPosition;
  LatLng _initialLatLng = LatLng(41.375969168654926, 2.186781542297567);
  bool _firstLocation = true;
  StreamSubscription<LocationData>? _initialLocationSubscription;
  StreamSubscription<LocationData>? _locationSubscription;
  WeatherFactory wf = WeatherFactory("bf0be3637e549c705d8d431f81044e51");
  Temperature? _currentTemp;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    _initialLocationSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('/markers').orderBy('name').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                try {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: _initialLatLng,
                      zoom: 14,
                    ),
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: Set.from(
                      snapshot.data!.docs.map(
                        (item) => Marker(markerId: MarkerId(item.id), position: LatLng(item['lat'], item['lng'])),
                      ),
                    ),
                  );
                } catch (e) {
                  return Center(
                    child: ListTile(
                      title: Text(
                        'Se ha producido un error. Comprueba tu conexión y vuelve a intentarlo',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }
              }),
          Positioned(
            left: 12.0,
            top: 12.0,
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                '${_currentTemp?.celsius?.toStringAsFixed(0) ?? '~'} ºC',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18.0
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialLatLng = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) async {
      _currentPosition = currentLocation;
      Weather w = await wf.currentWeatherByLocation(_currentPosition!.latitude!, _currentPosition!.longitude!);
      setState(() {
        _initialLatLng = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
        _currentTemp = w.temperature;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _initialLocationSubscription = location.onLocationChanged.listen((l) {
      if (_firstLocation) {
        _firstLocation = false;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 14),
          ),
        );
      }
    });
    _controller.complete(controller);
  }
}
