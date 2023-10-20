import 'dart:async';
//import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'components/drawer.dart';
import 'constants.dart';
import 'package:order_tracker/order_tracker.dart';

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

class OrderTrackerDemo extends StatefulWidget {
  const OrderTrackerDemo({super.key, required this.title});
  final String title;
  @override
  State<OrderTrackerDemo> createState() => _OrderTrackerDemoState();
}

class _OrderTrackerDemoState extends State<OrderTrackerDemo> {
  List<TextDto> InitialOrderDataList = [
    TextDto("Your order has been placed", ""),
  ];

  List<TextDto> OrderShippedDataList = [
    TextDto("Your order has been shipped", ""),
  ];

  List<TextDto> OrderOutOfDeliveryDataList = [
    TextDto("Your order is out for delivery", ""),
  ];

  List<TextDto> OrderDeviveredDataList = [
    TextDto("Your order has been delivered", ""),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: OrderTracker(
          status: Status.delivered,
          activeColor: Colors.blue,
          inActiveColor: Colors.grey[300],
          orderTitleAndDateList: InitialOrderDataList,
          shippedTitleAndDateList: OrderShippedDataList,
          outOfDeliveryTitleAndDateList: OrderOutOfDeliveryDataList,
          deliveredTitleAndDateList: OrderDeviveredDataList,
        ),
      ),
    );
  }
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(18.48813906054479, -69.96246698656097);
  static const LatLng destination =
      LatLng(18.601775799506562, -68.33475993750115);

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
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_source.png')
        .then((value) => (icon) {
              sourceIcon = icon;
            });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_destination.png')
        .then((value) => (icon) {
              destinationIcon = icon;
            });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_current_location.png')
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
