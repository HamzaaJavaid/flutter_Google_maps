import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class SearchPlaceAPIScreen extends StatefulWidget {
  const SearchPlaceAPIScreen({super.key});

  @override
  State<SearchPlaceAPIScreen> createState() => _SearchPlaceAPIScreenState();
}

class _SearchPlaceAPIScreenState extends State<SearchPlaceAPIScreen> {

//live location fetch
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


  //some constants




  late CameraPosition cameraPosition ;
  List<Marker> markers = [];
  TextEditingController controller = TextEditingController();
  Completer<GoogleMapController> googleMapController = Completer();
  bool listofPlacesVisibility = false;
  List suggestedPlaces = [];
  //var data ;

  Future<void> PredictPlace(String place) async{
    String placeAPI = "AIzaSyBglflWQihT8c4yf4q2MVa2XBtOrdAylmI";
    String baseURL ="https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String RequestURL = "$baseURL?input=$place&key=$placeAPI&sessiontoken=12382";

    final response = await http.get(Uri.parse(RequestURL));
   var  data  = jsonDecode(response.body);
    suggestedPlaces.clear();
    suggestedPlaces.add(data);
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
        appBar: AppBar(
          title: Text('Search Place Google API'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Search Place",
                  hintTextDirection: TextDirection.ltr,
                ),
                onChanged: (value)async{
                    listofPlacesVisibility = true;

                  await PredictPlace(value);
                  setState(() {});
                  //print(data['predictions'][0]['description']);
                  print(suggestedPlaces[0]['predictions'][0]['description']);

                },
              ),
              Stack(
                children: [
                  Container(
                    height: height/1.4,
                    width: width,
                    child: GoogleMap(
                      initialCameraPosition: cameraPosition ,
                      markers: Set.of(markers),
                      onMapCreated: (controllerr){
                        googleMapController.complete(controllerr);
                      },
                      onCameraMove: (latlng){

                      },
                      onTap: (latlng){
                        markers.clear();
                        markers.add(
                          Marker(
                            markerId: MarkerId('1'),
                            position: LatLng(latlng.latitude , latlng.longitude),
                          ),
                        );
                        setState(() {
                          listofPlacesVisibility = false;
                        });

                      },
                    ),
                  ),
                  Visibility(
                    visible: listofPlacesVisibility,
                    child: Center(
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Container(
                          height: height/5,
                          width: width/0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 5,
                                blurRadius: 2,
                                offset: Offset(1,1)
                              )
                            ]
                          ),
                          child: ListView.builder(
                              itemCount: suggestedPlaces.isEmpty==true ?0 :suggestedPlaces[0]['predictions'].length ,
                              //itemCount : 0,
                              //suggestedPlaces[0]['predictions'].length,
                              itemBuilder: (context,index){
                                // return Text('an');
                                return Column(
                                  children: [
                                    InkWell(
                                        onTap:() async {






                                          controller.clear();
                                          controller.text = suggestedPlaces[0]['predictions'][index]['description'].toString();
                                          print(suggestedPlaces[0]['predictions'][index]['description'].toString());
                                          GoogleMapController gMapController = await googleMapController.future;

                                          List<Location> locations = await locationFromAddress(controller.text);
                                          print(locations.reversed.last.longitude);
                                          print(locations.reversed.last.latitude);

                                          gMapController.animateCamera(CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: LatLng(locations.reversed.last.latitude , locations.reversed.last.longitude ),
                                                zoom: 15.4746,
                                              )
                                            ));
                                          cameraPosition = CameraPosition(
                                            target: LatLng(locations.reversed.last.latitude , locations.reversed.last.longitude ),
                                            zoom: 13.4746,
                                          );
                                          markers.clear();
                                          markers.add(
                                            Marker(
                                                markerId: MarkerId('1'),
                                              position: LatLng(locations.reversed.last.latitude , locations.reversed.last.longitude ),
                                            ),
                                          );

                                          setState(() {
                                            listofPlacesVisibility = false;
                                          });





                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(suggestedPlaces[0]['predictions'][index]['description'].toString()),
                                        )),
                                    Center(child: Text('----------------------------------'),),
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
