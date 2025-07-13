import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ipas_mobile/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/signin google/google_signin_api.dart';

class HomeLogin extends StatefulWidget {
  @override
  _HomeLoginState createState() => _HomeLoginState();
}

enum LoginStatus { notSignIn, signIn }

class _HomeLoginState extends State<HomeLogin> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _secureText = true;

  @override
  void initState() {
    super.initState();
    print('masuk ke login');
    getPref();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  savePref(String idPegawai, int value, String username, String name, String id,
      String branchId, String jenisLogin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("id_pegawai", idPegawai);
      preferences.setInt("value", value);
      preferences.setString("username", username);
      preferences.setString('name', name);
      preferences.setString("id", id);
      preferences.setString("branch_id", branchId);
      preferences.setString("loginGoogle", jenisLogin);
      // ignore: deprecated_member_use
      preferences.commit();
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http.post(Uri.parse(util.Api.urlLogin),
        body: {"username": username, "password": password});
    final data = jsonDecode(response.body);
    int valueManual = data['value'];
    if (valueManual == 1) {
      print("valuee nyaaa $valueManual ");
      String usernameAPI = data['data']['user_name'];
      String namaAPI = data['data']['full_name'];
      String id = data['data']['user_id'];
      String idPegawai = data['data']['id_Peg'];
      String branchId = data['data']['branch_id'];
      String idCabang = data['data']['id_cabang'];
      String cabangID = (branchId != null) ? branchId : idCabang;
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(idPegawai, valueManual, usernameAPI, namaAPI, id, cabangID,
            "manual");
      });
      EasyLoading.showSuccess('Login berhasil!');
    } else {
      EasyLoading.showError('Username atau password tidak cocok.');
    }
  }

  Future signInGoogle() async {
    final user = await GoogleSignInApi.login();

    if (user == null) {
      EasyLoading.showError('User tidak ditemukan');
      setState(() {
        GoogleSignInApi.logout();
      });
    } else {
      final response = await http
          .post(Uri.parse(util.Api.urlLogin), body: {"email": user.email});
      final data = jsonDecode(response.body);

      int valueApi = data['value'];
      if (valueApi == 1) {
        String usernameAPI = data['data']['user_name'];
        String namaAPI = data['data']['full_name'];
        String email = data['data']['email'];
        String id = data['data']['user_id'];
        String idPegawai = data['data']['id_Peg'];
        String branchId = data['data']['branch_id'];
        String idCabang = data['data']['id_cabang'];
        String cabangID = (branchId != null) ? branchId : idCabang;
        setState(() {
          _loginStatus = LoginStatus.signIn;
          // savePref(idPegawai, valueManual, usernameAPI, namaAPI, id, cabangID,"manual");
          savePref(idPegawai, valueApi, usernameAPI, namaAPI, id, cabangID,
              "google");
        });
        //print("login google berhasillllllll....");
        EasyLoading.showSuccess('Login berhasil!');
      } else {
        EasyLoading.showError('User tidak ditemukan');
        setState(() {
          GoogleSignInApi.logout();
        });
      }
    }
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      username = preferences.getString('username');

      _loginStatus = (value == 1) ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove('username');
      preferences.setInt("value", null);
      // ignore: deprecated_member_use
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
      /*Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => HomeLogin()));*/
      Navigator.pop(context);
    });
  }

  Future<void> infoInternet() async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Colors.white,
            elevation: 5,
            child: Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.clear, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Center(
                            child: Image.asset(
                                'assets/images/network_error.png',
                                width: 150,
                                height: 150)),
                        const SizedBox(height: 20),
                      const Center(
  child: Text(
    'Terjadi gangguan! Silahkan periksa koneksi internet Anda. Pastikan Data seluler atau Wifi aktif.',
    textAlign: TextAlign.center,
    style: TextStyle(
      height: 1.5, // ✅ line spacing multiplier (1.0 = default)
    ),
  ),
)
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    //ScreenUtil._instance = ScreenUtil()..init(context);
    //ScreenUtil._instance =
    //ScreenUtil(width: 750, height: 1334, allowFontScaling: true);

    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 100),
                  Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: ScreenUtil().setWidth(100),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 120.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: ScreenUtil().setHeight(100),
                      ),
                      Form(
                        key: _key,
                        child: Container(
                          width: double.infinity,
//      height: ScreenUtil().setHeight(500),
                          padding: EdgeInsets.only(bottom: 1),
                          decoration: BoxDecoration(
                              //color: Colors.grey.shade100,
                              //borderRadius: BorderRadius.circular(10.0),
                              // border: Border.all(
                              //     width: 1.0, color: Colors.grey.shade200),
                              ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text("Login",
                                //     style: TextStyle(
                                //         fontSize: ScreenUtil().setSp(21),
                                //         letterSpacing: .6)),
                                SizedBox(height: ScreenUtil().setHeight(10)),
                                Text("User ID",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14))),
                                TextFormField(
                                  // ignore: missing_return
                                  validator: (e) {
                                    if (e.length < 5) {
                                      return "Please insert UserID/Email/Nomor HP";
                                    }
                                  },
                                  onSaved: (e) => username = e,
                                  maxLength: 40,
                                  decoration: InputDecoration(
                                      hintText: "Masukan UserID...",
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.deepPurple.shade300,
                                      )),
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12.0)),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(20),
                                ),
                                Text("Password",
                                    style: TextStyle(
                                        fontFamily: "Poppins-Medium",
                                        fontSize: ScreenUtil().setSp(14))),
                                TextFormField(
                                  // ignore: missing_return
                                  validator: (e) {
                                    if (e.length < 5) {
                                      return "Please insert password";
                                    }
                                  },
                                  obscureText: _secureText,
                                  onSaved: (e) => password = e,
                                  maxLength: 15,
                                  decoration: InputDecoration(
                                      hintText: "Masukan Password...",
                                      suffixIcon: IconButton(
                                        onPressed: showHide,
                                        icon: Icon(_secureText
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        color: _secureText
                                            ? Colors.grey
                                            : Color(0xFFC2DD5F),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.deepPurple.shade300,
                                      )),
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12.0)),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(25),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple.shade700,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(50.0), // ✅ Biar rounded
                          ),
                        ),
                        onPressed: () {},
                        child: Container(
                            child: InkWell(
                          onTap: () {
                            print("sign manual");
                            if (_connectionStatus
                                .toString()
                                .contains('ConnectivityResult.none')) {
                              infoInternet();
                            } else {
                              check();
                            }
                            // check();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("SIGN IN",
                                  style: TextStyle(
                                      fontSize: 14, letterSpacing: 1.0)),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(Icons.login, color: Colors.white),
                            ],
                          ),
                        )),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15)),
                      Center(
                        child: Text(
                          "-or-",
                          style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            fontSize: ScreenUtil().setSp(18),
                            color: Colors.grey, // ✅ abu-abu
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple.shade700,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(50.0), // ✅ Biar rounded
                          ),
                        ),
                        onPressed: () {},
                        child: Container(
                            child: InkWell(
                          onTap: () async {
                            print("sign google");
                            if (_connectionStatus
                                .toString()
                                .contains('ConnectivityResult.none')) {
                              infoInternet();
                            } else {
                              await signInGoogle();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/logo_google.png',
                                  width: 25, height: 25),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Sign in With Google",
                                  style: TextStyle(
                                      fontSize: 14, letterSpacing: 1.0)),
                            ],
                          ),
                        )),
                      )
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     Text(
                      //       "New User? ",
                      //       style: TextStyle(fontFamily: "Poppins-Medium"),
                      //     ),
                      //     InkWell(
                      //       onTap: () {},
                      //       child: Text("SignUp",
                      //           style: TextStyle(
                      //               color: Color(0xFFC2DD5F),
                      //               fontFamily: "Poppins-Bold")),
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case LoginStatus.signIn:
        //return HomePage(signOut);
        //return HomeSecond(_selectedIndex);
        return MainNavBar();

        break;
    }
  }
}
