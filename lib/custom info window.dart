import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class InfoWindowCustom extends StatefulWidget {
  const InfoWindowCustom({super.key});

  @override
  State<InfoWindowCustom> createState() => _InfoWindowCustomState();
}

class _InfoWindowCustomState extends State<InfoWindowCustom> {


  CustomInfoWindowController infoWindowController = CustomInfoWindowController();
 late  CameraPosition cameraPosition;
 List<Marker> markers=[];
 List<LatLng> locations_latlng = [
   LatLng(34.03672419883914, 71.56501097393256),
   LatLng(34.03636423152987, 71.56918435319744),
   LatLng(34.03652133465173, 71.565696044866),
   LatLng(34.036976932059765, 71.56873883555727),
   LatLng(34.0332847401735, 71.56667079692072),
  // LatLng(34.0332847401735, 71.56667079692072),
 ];


 Future<void> _determinePosition() async {
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


   getLocation();

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
     cameraPosition = CameraPosition(
       target: LatLng(position.latitude, position.longitude),
       zoom: 13.4746,
     );

     markers.add(
         Marker(markerId: MarkerId('x'),position: LatLng(position.latitude,position.longitude),infoWindow: InfoWindow(title: "Current Location:  ${placemarks[0].name}"))
     );
     print('Done');
   });
 }
 loadData(){
   
   for(int i =  0 ; i<locations_latlng.length ; i ++){
     markers.add(
       Marker(
           markerId: MarkerId(i.toString()),
         position: locations_latlng[i],

         onTap: (){
            infoWindowController.addInfoWindow!(
             Container(
               color: Colors.white,
               child: Text('This is Marker # $i'),
             ),
              locations_latlng[i],
            );

         },
       )
     );
     setState(() {

     });

     
   }
 }


 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  @override

  Widget build(BuildContext context) {
   final height = MediaQuery.of(context).size.height;
   final width = MediaQuery.of(context).size.width;
    try{
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
                      child: Container(
                        height: height/1.3,
                        width: width/1,
                        child: GoogleMap(
                          initialCameraPosition: cameraPosition,
                          markers: Set<Marker>.of(markers),
                          onMapCreated: (controller){
                            infoWindowController.googleMapController = controller;
                          },
                          onCameraMove: (latlng){
                            infoWindowController.onCameraMove!();
                          },
                          onTap: (latlng){
                            infoWindowController.hideInfoWindow!();

                          },
                        ),
                      ),
                    ),
                    CustomInfoWindow(
                      controller: infoWindowController,
                      height: height/30,
                      width: width/3,
                    ),
                  ],
                ),
                MaterialButton(
                  color: Colors.green,
                  height: height/12,
                  minWidth: width/1.2,
                  onPressed: (){

                    loadData();
                    setState(() {

                    });

                  },child: Text('Load Data' , style: TextStyle(
                  color: Colors.white,
                  fontSize: 19
                ),),)
              ],
            ),
          ),
        ),
      );
    }
        catch(e){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
        }
  }
}








/*
class InfoWindowCustom extends StatefulWidget {
  const InfoWindowCustom({super.key});

  @override
  State<InfoWindowCustom> createState() => _InfoWindowCustomState();
}

class _InfoWindowCustomState extends State<InfoWindowCustom> {


  CustomInfoWindowController customWindowController  = CustomInfoWindowController();

   CameraPosition initialCameraPosition = CameraPosition(
    target:LatLng(34.03672419883914, 71.56501097393256),
    zoom: 13.4746,
  );
  List<Marker> _markers = [];
  List<LatLng> listOfCoordinates = [
    LatLng(34.03672419883914, 71.56501097393256),
    LatLng(34.03636423152987, 71.56918435319744),
    LatLng(34.03652133465173, 71.565696044866),
    LatLng(34.036976932059765, 71.56873883555727),
    LatLng(34.0332847401735, 71.56667079692072),
    LatLng(34.0332847401735, 71.56667079692072),

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
      initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 13.4746,
      );

     // _markers.add(Marker(markerId: MarkerId('1'),position: LatLng(position.latitude,position.longitude),infoWindow: InfoWindow(title: "Islamabad B-17 ${placemarks[0].name}")));
      print('Done');
    });
  }


  loadMarkers(){

    for(int i = 0 ; i<listOfCoordinates.length  ; i++){
      _markers.add(
        Marker(
            markerId: MarkerId(i.toString()),
          position: listOfCoordinates[i],
          icon: BitmapDescriptor.defaultMarker,
            onTap: (){
              print('sadjsad');
              customWindowController.addInfoWindow!(
                Text('dhdhadsuhuashuduashduisa'),
                LatLng(34.03672419883914, 71.56501097393256),
              );
            }
        )
      );
      setState(() {

      });
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMarkers();
   // _determinePosition();

  }

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.of(context).size.width;
    final height  = MediaQuery.of(context).size.height;

      return Scaffold(
        body: Stack(
          children: [

            GoogleMap(
                initialCameraPosition: initialCameraPosition,
              markers: Set.of(_markers),
              onMapCreated: (GoogleMapController controller){
                  customWindowController.googleMapController  = controller;
              },
              onTap: (position){
                  customWindowController.hideInfoWindow!();
              },
              onCameraMove: (onCameraMove){
                  customWindowController.onCameraMove!();
              },
            ),
            CustomInfoWindow(
              controller: customWindowController,
              width: width/3,
              height: height/20,
              offset: 35,
            ),
            
          ],
        ),
      );


  }
}

*/
