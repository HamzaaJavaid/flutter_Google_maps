import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Google Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  Completer<GoogleMapController> googleMapController = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  List<Marker> markers = [
    Marker(
      markerId: MarkerId('1'),
    position:  LatLng(37.42796133580664, -122.085749655962),
    infoWindow: InfoWindow(title: "Your Location .."),

    )
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: GoogleMap(
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        markers: Set.of(markers),
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (controller){
          googleMapController.complete(controller);
        },
        onTap: (LatLng){
          print(LatLng);

        },

      )

    );
  }
}
