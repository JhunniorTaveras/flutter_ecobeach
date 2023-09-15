import 'dart:async';
//import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'components/drawer.dart';
import 'constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = [''];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.access_alarm),
      onPressed: () {
        query = '';
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.access_alarm),
      onPressed: () {
        close(context, null);
      },
    );
  }
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4218, -122.0855);
  static const LatLng destination = LatLng(37.4116, -122.0713);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
          (location) => {currentLocation = location},
        );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 15, target: LatLng(newLoc.latitude!, newLoc.longitude!)),
        ),
      );
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    //if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ));
    setState(() {});
    //}
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "C:/Users/jtave/OneDrive/Documents/Intec/Trimestre 17/Proyecto Final Tres/ecobeach/ecobeach/assets/Pin_source.png")
        .then((value) => (icon) {
              sourceIcon = icon;
            });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "C:/Users/jtave/OneDrive/Documents/Intec/Trimestre 17/Proyecto Final Tres/ecobeach/ecobeach/assets//Pin_destination.png")
        .then((value) => (icon) {
              destinationIcon = icon;
            });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            "C:/Users/jtave/OneDrive/Documents/Intec/Trimestre 17/Proyecto Final Tres/ecobeach/ecobeach/assets//Pin_current_location.png")
        .then((value) => (icon) {
              currentLocationIcon = icon;
            });
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ECOBEACH"),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search))
        ],
        backgroundColor: const Color.fromARGB(255, 13, 72, 161),
      ),
      drawer: MyDrawer(
        onSignOut: signOut,
      ),
      body: currentLocation == null
          ? const Center(
              child: Text("Cargando"),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15,
              ),
              polylines: {
                Polyline(
                    polylineId: const PolylineId("route"),
                    points: polylineCoordinates,
                    color: Colors.blue,
                    width: 6,
                    visible: true)
              },
              markers: {
                Marker(
                    markerId: const MarkerId("currentLocation"),
                    icon: currentLocationIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    visible: true),
                Marker(
                    markerId: const MarkerId("source"),
                    icon: sourceIcon,
                    position: sourceLocation,
                    visible: true),
                Marker(
                    markerId: const MarkerId("destination"),
                    icon: destinationIcon,
                    position: destination,
                    visible: true),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
