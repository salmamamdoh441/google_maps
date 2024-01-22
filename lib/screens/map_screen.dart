import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;


  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void searchLocation() async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: MAPBOX_ACCESS_TOKEN,
      mode: Mode.overlay,
      language: "ar",
      components: [Component(Component.country, "EG")],
    );

    if (prediction != null) {
      GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: MAPBOX_ACCESS_TOKEN);
      PlacesDetailsResponse details = await places.getDetailsByPlaceId(prediction.placeId!);

      if (details.result != null && details.result.geometry != null && details.result.geometry!.location != null) {
        setState(() {
          myPosition = LatLng(
            details.result.geometry!.location.lat,
            details.result.geometry!.location.lng,
          );
        });
      } else {
        // Handle the case where the details are incomplete or null
        print('Details are incomplete or null');
      }
    } else {
      // Handle the case where the prediction is null
      print('Prediction is null');
    }
  }





  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      print(myPosition);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                  center: myPosition, minZoom: 5, maxZoom: 25, zoom: 18),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12'
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (context) {
                        return Container(
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: searchLocation,
                    tooltip: 'Search Location',
                    child: Icon(Icons.search),
                  ),
                ),

              ],
            ),

    );
  }
}
