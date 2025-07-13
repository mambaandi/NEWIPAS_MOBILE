import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/ui/login.dart';
import 'package:ipas_mobile/widgets/profile_widget.dart';
import 'package:ipas_mobile/widgets/signin%20google/google_signin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  //const ProfilePage({Key key}) : super(key: key);\
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String loginGoogle = "";
  String userid = "";
  String name = "";
  String branchID = "";
  String username = "";
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getPref();

    super.initState();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      //developer.log('Couldn\'t check connectivity status', error: e);
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

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userid = preferences.getString("id");
      loginGoogle = preferences.getString("loginGoogle");
      name = preferences.getString("name");
      branchID = preferences.getString("branch_id");
      username = preferences.getString("username");
    });
  }

  signOut() async {
    EasyLoading.showInfo("Sign Out");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove('loginGoogle');
      preferences.remove('username');
      //preferences.remove('value');
      preferences.setInt("value", 0);
      // ignore: deprecated_member_use
      preferences.commit();
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => HomeLogin()));
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
                              height:
                                  1.5, // ✅ line spacing multiplier (1.0 = default)
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Container(
              width: 100,
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: ExactAssetImage('assets/images/Sample.png'),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(.5),
                  width: 5.0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$name',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 24,
                ),
              ],
            ),
            Text(
              '$username',
              style: TextStyle(
                color: Colors.black.withOpacity(.3),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileWidget(
                  icon: Icons.person,
                  title: 'My Profile',
                  link: 0,
                ),
                ProfileWidget(
                  icon: Icons.settings,
                  title: 'Settings',
                  link: 1,
                ),
                ProfileWidget(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  link: 2,
                ),
                ProfileWidget(
                  icon: Icons.chat,
                  title: 'FAQs',
                  link: 3,
                ),
                ProfileWidget(
                  icon: Icons.share,
                  title: 'Share',
                  link: 4,
                ),
                SizedBox(
                  height: 50,
                ),
                Card(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(55),
                    ),
                    elevation: 1,
                    child: ListTile(
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 24,
                            ),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ]),
                      onTap: () {
                        print("login google $loginGoogle");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: Column(children: [
                                const Text('Pemberitahuan'),
                                Divider(color: Colors.grey.shade400)
                              ]),
                              content: Text('Yakin akan keluar dari aplikasi?'),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Tidak'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Ya, Keluar!'),
                                  onPressed: () async {
                                    if (_connectionStatus
                                        .toString()
                                        .contains('ConnectivityResult.none')) {
                                      infoInternet();
                                    } else {
                                      if (loginGoogle == "google") {
                                        await GoogleSignInApi.logout();
                                        signOut();
                                      } else {
                                        signOut();
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ))
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
