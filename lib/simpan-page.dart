import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:presensi/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  Future savePresensi(latitude, longitude) async {
    try {
      final String token = await _token;
      SavePresensiResponseModel savePresensiResponseModel;
      Map<String, String> body = {
        "latitude": latitude.toString(),
        "longitude": longitude.toString()
      };

      // Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};

      final Map<String, String> headers = {
        // 'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("Token di save presensi yaah: $token");

      var response = await myHttp.post(
          // Uri.parse("https://mkp-projects.000webhostapp.com/api/save-presensi"),
          Uri.parse("http://127.0.0.1:8000/api/save-presensi"),
          body: body,
          headers: headers);

      if (response.statusCode == 200) {
        // Successful response, authorization is true
        print("Authorization is true");
        // Handle your data here, e.g., parse response.body
        Map<String, dynamic> data = json.decode(response.body);
        print("Data: $data");
      } else {
        // Failed response, authorization is false
        print("Authorization is false");
        print("Error: ${response.reasonPhrase}");
        // You may want to handle errors here, e.g., show an error message
      }

      savePresensiResponseModel =
          SavePresensiResponseModel.fromJson(json.decode(response.body));

      if (savePresensiResponseModel.success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
      }
    } catch (e) {
      print("Error POST data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
      ),
      body: FutureBuilder<LocationData?>(
          future: _currenctLocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data;
              print("KODING : " +
                  currentLocation.latitude.toString() +
                  " | " +
                  currentLocation.longitude.toString());
              return SafeArea(
                  child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currentLocation.latitude!,
                              currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currentLocation.latitude!,
                              longitude: currentLocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        savePresensi(currentLocation.latitude,
                            currentLocation.longitude);
                      },
                      child: Text("Simpan Presensi"))
                ],
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
