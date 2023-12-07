import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  List<Datum> riwayat = [];
  Datum? hariIni;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      String? token = prefs.getString("token");
      if (token != null && token.isNotEmpty) {
        print("Token exists: $token");
        return token;
      } else {
        print("Token not found or empty");
        // You can handle the case when the token is not available.
        // For example, you might want to redirect the user to the login screen.
        return "";
      }
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getData() async {
    try {
      final String token = await _token;

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("Token in getData yaah: $token");

      var response = await myHttp.get(
        // Uri.parse('https://mkp-projects.000webhostapp.com/api/get-presensi'),
        Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
        headers: headers,
      );

      // print("DATA: " + response.body);

      // if (response.statusCode == 200) {
      //   // Successful response, authorization is true
      //   print("Authorization is true");
      //   // Handle your data here, e.g., parse response.body
      //   Map<String, dynamic> data = json.decode(response.body);
      //   print("Data: $data");
      // } else {
      //   // Failed response, authorization is false
      //   print("Authorization is false");
      //   print("Error: ${response.reasonPhrase}");
      //   // You may want to handle errors here, e.g., show an error message
      // }

      homeResponseModel =
          HomeResponseModel.fromJson(json.decode(response.body));
      riwayat.clear();

      homeResponseModel!.data.forEach((element) {
        if (element.isHariIni) {
          hariIni = element;
        } else {
          riwayat.add(element);
        }
      });
      // print(hariIni?.pulang);
    } catch (e) {
      // Handle the exception here, you can print an error message or log the details.
      print("Error fetching data: $e");
      // You might want to rethrow the exception if you want to propagate it further.
      // throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: _name,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              if (snapshot.hasData) {
                                print(snapshot.data);
                                return Text(snapshot.data!,
                                    style: TextStyle(fontSize: 18));
                              } else {
                                return Text("-",
                                    style: TextStyle(fontSize: 18));
                              }
                            }
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 400,
                        decoration: BoxDecoration(color: Colors.blue[800]),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: [
                            Text(hariIni?.tanggal ?? '-',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(hariIni?.masuk ?? '-',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24)),
                                    Text("Masuk",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      (hariIni?.pulang == "00:00")
                                          ? '-'
                                          : hariIni?.pulang ?? '-',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    ),
                                    Text("Pulang",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16))
                                  ],
                                )
                              ],
                            )
                          ]),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Riwayat Presensi"),
                      Expanded(
                        child: ListView.builder(
                          itemCount: riwayat.length,
                          itemBuilder: (context, index) => Card(
                            child: ListTile(
                              leading: Text(riwayat[index].tanggal),
                              title: Row(children: [
                                Column(
                                  children: [
                                    Text(riwayat[index].masuk,
                                        style: TextStyle(fontSize: 18)),
                                    Text("Masuk",
                                        style: TextStyle(fontSize: 14))
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text(
                                        riwayat[index].pulang == "00:00"
                                            ? "-"
                                            : riwayat[index].pulang,
                                        style: TextStyle(fontSize: 18)),
                                    Text("Pulang",
                                        style: TextStyle(fontSize: 14))
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (hariIni?.pulang == "00:00" || hariIni?.pulang == null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SimpanPage()))
                  .then((value) {
                setState(() {});
              });
            }
          },
          child: (hariIni?.pulang != "00:00")
              ? Icon(Icons.add)
              : Icon(Icons.check, color: Colors.green),
        ));
  }
}
