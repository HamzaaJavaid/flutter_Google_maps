import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mapsflutter/custom%20info%20window.dart';

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
      debugShowCheckedModeBanner: false,
      //home: const MyHomePage(title: 'Flutter Google Map'),
      home: InfoWindowCustom(),
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

  LatLng latlng = LatLng(34.120155, 72.470154);

    late CameraPosition  _kGooglePlex ;

  List<Marker> markers = [
  ];




  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await getLocation();
  }

  Future getLocation()async{




    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Latitude :- ${position.latitude}");
    print("Longitude :- ${position.longitude}");
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print('---');
    print(placemarks);
    print(placemarks[0].name);
    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 13.4746,
      );

      markers.add(
          Marker(markerId: MarkerId('1'),position: LatLng(position.latitude,position.longitude),infoWindow: InfoWindow(title: "Islamabad B-17 ${placemarks[0].name}"))
      );
      print('Done');
    });
  }


  //33.685504,72.8399872

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
   // getLocation();
  }

  @override
  Widget build(BuildContext context) {

   try{
     return Scaffold(

       appBar: AppBar(

         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

         title: Text(widget.title),
       ),
       body: SafeArea(
         child: GoogleMap(
           zoomControlsEnabled: true,
           compassEnabled: true,
           mapType: MapType.normal,
           markers: Set.of(markers),
           myLocationEnabled: true,
           initialCameraPosition: _kGooglePlex,
           onMapCreated: (controller){
             googleMapController.complete(controller);
           },
           onTap: (LatLng){



           },

         ),
       ),
       floatingActionButton: FloatingActionButton(
         child: Icon(Icons.location_disabled),
         onPressed: ()async{


           print(markers[0].position);
           GoogleMapController MapController = await googleMapController.future;
           MapController.animateCamera(
               CameraUpdate.newCameraPosition(
                   CameraPosition(target: markers[0].position , zoom: 14.4746)
               )
           );





         },
       ),

     );
   }
       catch(e){
     return Scaffold(
       appBar: AppBar(

         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

         title: Text(widget.title),
       ),
       body: Center(
         child: CircularProgressIndicator(),
       ),
     );
       }
  }
}
