import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:PresensiPro/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:PresensiPro/models/login-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage()))
            .then((value) {
          setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp.post(
        Uri.parse('https://mkp-projects.000webhostapp.com/api/login'),
        // Uri.parse('http://127.0.0.1:8000/api/login'),
        body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email atau password salah")));
    } else {
      loginResponseModel =
          LoginResponseModel.fromJson(json.decode(response.body));
      print('HASIL ' + response.body);
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
    }
  }

  Future saveUser(token, name) async {
    try {
      print("LEWAT SINI " + token + " | " + name);
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()))
          .then((value) {
        setState(() {});
      });
    } catch (err) {
      print('ERROR :' + err.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

//PERUBAHAN FRONTEND DARI SINI===============================================================
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/uin.png',
                        height: 60,
                        width: 60,
                      ),
                      Image.asset(
                        'images/ptipd.png',
                        height: 100,
                        width: 100,
                      ),
                      Image.asset(
                        'images/app.png',
                        height: 60,
                        width: 60,
                      ),
                    ],
                  ),
                  const Center(
                    child: Text(
                      "Presensi Praktis,\nKehadiran Efisien!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 34,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Text(
                      'Teknologi Absensi, Pintar, Cepat,\ndan Akurat, Kunci Kehadiran\nyang Efisien!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4F4F4FCC),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   "Email",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "No Pegawai/NIP",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Text(
                        //   "Password",
                        //   style: TextStyle(fontWeight: FontWeight.bold),
                        // ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null // Disable the button when loading
                              : () {
                                  setState(() {
                                    isLoading =
                                        true; // Set loading state to true
                                  });
                                  login(emailController.text,
                                          passwordController.text)
                                      .then((_) {
                                    // Set loading state back to false after login completes
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                },
                          child: Text(
                            isLoading
                                ? "Loading..."
                                : "Log In", // Change text based on loading state
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                            primary: Color(0xFF318CA0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ])),
      ),
    );
  }
}
