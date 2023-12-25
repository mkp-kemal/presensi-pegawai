import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:PresensiPro/models/home-response.dart';
import 'package:PresensiPro/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as myHttp;
import 'package:http/http.dart' as http;

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
        // print("Token exists: $token");
        return token;
      } else {
        print("Token not found or empty");
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
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // print("Token in getData yaah: $token");

      var response = await http.get(
        Uri.parse('https://mkp-projects.000webhostapp.com/api/get-presensi'),
        // Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
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
      print("Error fetching data: $e");
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
                                return Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                  ),
                                );
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
                        width: 354,
                        height: 257.71,
                        margin: EdgeInsets.only(top: 26, left: 30, right: 30),
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1.00, -0.01),
                            end: Alignment(1, 0.01),
                            colors: [Color(0xFF38B6FF), Color(0xFF38B6FF)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 30,
                              top: 73,
                              child: Text(
                                hariIni?.masuk ?? '-',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 205,
                              top: 73,
                              child: Text(
                                (hariIni?.pulang == "00:00")
                                    ? '-'
                                    : hariIni?.pulang ?? '-',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              top: 23,
                              child: SizedBox(
                                width: 318,
                                child: Text(
                                  hariIni?.tanggal ?? '-',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 196,
                              top: 189,
                              child: Container(
                                width: 125,
                                height: 40,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFEFFFE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (hariIni?.pulang == "00:00" ||
                                          hariIni?.pulang == null) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    SimpanPage()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary:
                                          Color(0xFFFEFFFE), // Background color
                                      onPrimary: Color(0xFF2596be),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ), // Text Color (Foreground color)
                                    ),
                                    child: (hariIni?.pulang == "00:00")
                                        ? Text(
                                            "Isi Kehadiran",
                                            style: TextStyle(fontSize: 12),
                                          )
                                        : Icon(Icons.check,
                                            color: Colors.green)),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              top: 120,
                              child: Text(
                                'Pukul Masuk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 206,
                              top: 120,
                              child: Text(
                                'Pukul Keluar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                          ],
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
