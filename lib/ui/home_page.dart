import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:ipas_mobile/model/absensi_model.dart';
import 'package:ipas_mobile/model/util.dart';
import 'package:ipas_mobile/ui/camera_absensi.dart';
// import 'package:ipas_mobile/ui/list_cuti.dart';
// import 'package:ipas_mobile/ui/list_inventaris.dart';
// import 'package:ipas_mobile/ui/list_reimburse.dart';
import 'package:ipas_mobile/ui/histori_absensi.dart';
import 'package:ipas_mobile/widgets/color_palette.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:slide_digital_clock/slide_digital_clock.dart';

const spinkit = SpinKitWave(
  color: Colors.deepPurple,
  type: SpinKitWaveType.center,
  itemCount: 7,
  size: 30.0,
);

class HomePage extends StatefulWidget {
  final VoidCallback signOut;

  HomePage(this.signOut);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<AbsenModel>> listAbsen = Future.value([]);
  String tanggalCheckin;
  String tanggalCheckout;
  String jamCheckin;
  String jamCheckout;
  String userid = "";
  String loginGoogle = "";
  String name = "";
  String branchID = "";
  String _image;
  String alamat = '';
  String id = '';
  String longlat = '';
  File selfie;
  int ambilStatus;
  int checkStatus; //1=sudah checkin; 0=sudah logout
  int gpsAktif; //1=aktif 0=nonaktif
  var now = DateTime.now();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    requestLocationPermission();
    TrustLocation.start(5);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getPref();
    super.initState();
  }

  saveStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('status', 1);
  }

  removeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('status');
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userid = preferences.getString("id");
      loginGoogle = preferences.getString("loginGoogle");
      name = preferences.getString("name");
      branchID = preferences.getString("branch_id");
      ambilStatus = preferences.getInt('status');
      //print('login google=$loginGoogle');
      //print("userid=$userid");
      //print("name=$name");
      loadHistoriAbsensi();
    });
  }

  void signOut() {
    setState(() {
      widget.signOut();
      print('berhasil logout');
    });
  }

  loadHistoriAbsensi() {
    fetchLastHistoriAbsensi(userid).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          listAbsen = Future.value(value);
        });
      }
    });
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

  /// request location permission at runtime.
  Future<void> requestLocationPermission() async {
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      gpsAktif = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Column(children: [
              const Text('Alert'),
              Divider(color: Colors.grey.shade400)
            ]),
            content: Text(
                'Izinkan aplikasi mengakses lokasi dan kamera diperangkat Anda terlebih dahulu.'),
            actions: <Widget>[
              ElevatedButton.icon(
                icon: Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
                label: const Text('Cek Ulang'),
                onPressed: () {
                  setState(() {
                    requestLocationPermission();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    final statusKamera = await Permission.camera.request();
    final statusMikropon = await Permission.microphone.request();
    if (status == PermissionStatus.granted &&
        statusKamera == PermissionStatus.granted &&
        statusMikropon == PermissionStatus.granted) {
      gpsAktif = 1;
      //EasyLoading.showInfo('GPS dan kamera aktif');
    } else if (status == PermissionStatus.denied &&
        statusKamera == PermissionStatus.denied &&
        statusMikropon == PermissionStatus.denied) {
      gpsAktif = 0;
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
      pageCheckCamera(context);
    } else if (status == PermissionStatus.permanentlyDenied &&
        statusKamera == PermissionStatus.permanentlyDenied &&
        statusMikropon == PermissionStatus.permanentlyDenied) {
      gpsAktif = 0;
      // pageCheckCamera(context);
    }
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
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          ClipPath(
            clipper:
                CustomShape(), // this is my own class which extendsCustomClipper
            child: Container(
              height: 210,
              color: ColorPalette.temaColor.shade200,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 60, left: 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      "Halo, $name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Card(
                            elevation: 5.0,
                            margin: EdgeInsets.only(top: 100, bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                                height: 150,
                                width: 310,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/banner4.png'),
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                                child: Column(children: [
                                  SizedBox(height: 20),
                                  (ambilStatus == 1 || checkStatus == 1)
                                      ? Text("Jangan lupa untuk Check Out ")
                                      : Text("Saat ini Anda belum Check In "),
                                  SizedBox(height: 5),
                                  DigitalClock(
                                    is24HourTimeFormat: true,
                                    minuteDigitDecoration: BoxDecoration(
                                        color: Colors.transparent),
                                    secondDigitDecoration: BoxDecoration(
                                        color: Colors.transparent),
                                    areaDecoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    colon: Text(
                                      ":",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    hourMinuteDigitTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                    secondDigitTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  new MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    elevation: 2.0,
                                    height: 40.0,
                                    minWidth: 250.0,
                                    color: ColorPalette.temaColor,
                                    textColor: Colors.white,
                                    child:
                                        (ambilStatus == 1 || checkStatus == 1)
                                            ? new Text("Check Out Sekarang")
                                            : new Text("Check In Sekarang"),
                                    onPressed: () => {
                                      setState(() {
                                        pageCheckCamera(context);
                                        //runCamera(context);
                                      })
                                    },
                                    splashColor: Colors.redAccent,
                                  ),
                                ])),
                          ),
                          SizedBox(width: 15),
                          Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image.asset(
                              'assets/images/banner1.png',
                              fit: BoxFit.fill,
                              height: 150,
                              width: 310,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.only(top: 100, bottom: 20),
                            elevation: 5,
                          ),
                          SizedBox(width: 15),
                          Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image.asset(
                              'assets/images/banner2.png',
                              fit: BoxFit.fill,
                              height: 150,
                              width: 310,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.only(top: 100, bottom: 20),
                            elevation: 5,
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                /*Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(children: [
                          InkWell(
                              onTap: () {
                                EasyLoading.showInfo("Belum tersedia.");
                                /*Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return ListInven();
                                  }),
                                );*/
                              },
                              child: Column(children: [
                                Image.asset('assets/images/icon1.png',
                                    fit: BoxFit.fill, height: 105),
                                Container(
                                  height: 30,
                                  padding: EdgeInsets.all(1),
                                  margin: EdgeInsets.all(1),
                                  child: Row(children: [
                                    SizedBox(height: 10),
                                    Text("Inventaris",
                                        style: TextStyle(fontSize: 15)),
                                    Icon(Icons.arrow_forward_outlined,
                                        size: 20),
                                  ]),
                                )
                              ])),
                        ]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                      ),
                      SizedBox(width: 5),
                      /*Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(children: [
                          InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return ListReimb();
                                  }),
                                );
                              },
                              child: Column(children: [
                                Image.asset('assets/images/icon3.png',
                                    fit: BoxFit.fill, height: 105),
                                Container(
                                  height: 30,
                                  padding: EdgeInsets.all(1),
                                  margin: EdgeInsets.all(1),
                                  child: Row(children: [
                                    SizedBox(height: 10),
                                    Text("Reimburse",
                                        style: TextStyle(fontSize: 15)),
                                    Icon(Icons.arrow_forward_outlined,
                                        size: 15),
                                  ]),
                                )
                              ])),
                        ]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                      ),*/
                      SizedBox(width: 5),
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(children: [
                          InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return ListCuti();
                                  }),
                                );
                              },
                              child: Column(children: [
                                Image.asset('assets/images/icon2.png',
                                    fit: BoxFit.fill, height: 105),
                                Container(
                                  height: 30,
                                  padding: EdgeInsets.all(1),
                                  margin: EdgeInsets.all(1),
                                  child: Row(children: [
                                    SizedBox(height: 10),
                                    Text("Ajukan Cuti",
                                        style: TextStyle(fontSize: 15)),
                                    Icon(Icons.arrow_forward_outlined,
                                        size: 15),
                                  ]),
                                )
                              ])),
                        ]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                      ),
                    ])),*/
                SizedBox(height: 15),
                Row(children: [
                  SizedBox(width: 20),
                  Expanded(
                      flex: 3,
                      child: Text("Histori Terakhir",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 1,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return ProfilAbsensi();
                              }),
                            );
                          },
                          child: Icon(Icons.history,
                              size: 25, color: Colors.black))),
                ]),
                SizedBox(height: 10),
                Container(
                  height: 430,
                  child: listHistoriAbsensi(),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          /*Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 50, right: 20),
              child: IconButton(
                icon: Image.asset(
                  'assets/images/Sample.png',
                ),
                iconSize: 40,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Column(children: [
                          const Text('Alert'),
                          Divider(color: Colors.grey.shade400)
                        ]),
                        content: Text('Keluar dari aplikasi ?'),
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
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              if (loginGoogle.contains('google')) {
                                print('masuk sini nih yg google');
                                await GoogleSignInApi.logout();
                                preferences.remove('loginGoogle');
                                signOut();
                              } else {
                                preferences.remove('loginGoogle');
                                signOut();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),*/
        ],
      ),
      //bottomNavigationBar: menuUtama(0, context),
    );
  }

  Future<void> runCamera(context) async {
    var res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => CameraAbsensi()));
    //Navigator.pop(context);
    if (res != null && res[3] != null && res[3] != "") {
      setState(() {
        _image = res[1];
        alamat = res[0];
        id = res[2];
        longlat = res[3];
        selfie = File(_image);
        //pageCheckIn(context);
        if (ambilStatus == 1 || checkStatus == 1) {
          setState(() {
            createCheckOut();
          });
        } else {
          setState(() {
            createCheckIn();
          });
        }
      });
    } else {
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
            content: Text(
                'Aplikasi membutuhkan akses GPS untuk membantu mencatat kehadiran Anda. Silahkan aktifkan!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Ya, Saya mengerti.'),
                onPressed: () async {
                  await openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> pageCheckCamera(context) async {
    final pilihanStatus =
        (ambilStatus == 1 || checkStatus == 1) ? 'Check-out' : 'Check-in';
    final status = await Permission.locationWhenInUse.request();
    final statusKamera = await Permission.camera.request();
    final statusMikropon = await Permission.microphone.request();
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          padding: EdgeInsets.all(10),
          //height: 90%,
          child: Column(
            children: [
              Row(children: [
                SizedBox(width: 50),
                Container(
                  width: 250,
                  child: Text("Pemberitahuan",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18)),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close,
                        size: 40, color: Colors.grey.shade300)),
              ]),
              Divider(color: Colors.grey.shade400),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    (status != PermissionStatus.granted ||
                            statusKamera != PermissionStatus.granted ||
                            statusMikropon != PermissionStatus.granted)
                        ? Text(
                            'Aplikasi membutuhkan akses kamera dan lokasi pada perangkat Anda untuk melakukan $pilihanStatus .')
                        : Text('Yakin akan $pilihanStatus ?'),
                    (status != PermissionStatus.granted ||
                            statusKamera != PermissionStatus.granted ||
                            statusMikropon != PermissionStatus.granted)
                        ? Column(
                            children: [
                              SizedBox(height: 30),
                              Container(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Icon(Icons.info_outline,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 5),
                                    Text(
                                      "Silahkan aktifkan.",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ])),
                              SizedBox(height: 30),
                              new MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 0.0,
                                height: 40.0,
                                minWidth: 300.0,
                                color: Colors.grey.shade300,
                                textColor: ColorPalette.temaColor,
                                child: new Text("Atur ulang"),
                                onPressed: () async {
                                  setState(() async {
                                    //requestLocationPermission();
                                    await openAppSettings();
                                    Navigator.pop(context);
                                  });
                                },
                              )
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(height: 60),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 2.0,
                                height: 40.0,
                                minWidth: 300.0,
                                color: ColorPalette.temaColor,
                                textColor: Colors.white,
                                child: new Text("Ya, Benar"),
                                onPressed: () async {
                                  if (_connectionStatus
                                      .toString()
                                      .contains('ConnectivityResult.none')) {
                                    infoInternet();
                                  } else {
                                    var res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => CameraAbsensi()));
                                    Navigator.pop(context);
                                    if (res != null &&
                                        res[3] != null &&
                                        res[3] != "") {
                                      setState(() {
                                        _image = res[1];
                                        alamat = res[0];
                                        id = res[2];
                                        longlat = res[3];
                                        selfie = File(_image);
                                        //pageCheckIn(context);
                                        if (ambilStatus == 1 ||
                                            checkStatus == 1) {
                                          setState(() {
                                            createCheckOut();
                                          });
                                        } else {
                                          setState(() {
                                            createCheckIn();
                                          });
                                        }
                                      });
                                    } else {
                                      pageCheckCamera(context);
                                    }
                                  }
                                },
                                splashColor: Colors.redAccent,
                              ),
                            ],
                          )
                  ])),
            ],
          ),
        ),
      ),
    );
  }

  // Future createCheckIn() async {
  //   // ignore: deprecated_member_use
  //   var stream = new http.ByteStream(DelegatingStream.typed(selfie.openRead()));
  //   var length = await selfie.length();
  //   var multipartFile = new http.MultipartFile("image_checkin", stream, length,
  //       filename: path.basename(selfie.path));

  //   var req = http.MultipartRequest('POST', Uri.parse(util.Api.urlCheckIn))
  //     ..headers['Content-Type'] = 'multipart/form-data'
  //     ..fields['id_user'] = '$id'
  //     ..fields['alamat_checkin'] = '$alamat'
  //     ..fields['longlat_checkin'] = '$longlat'
  //     ..files.add(multipartFile);
  //   await req.send();

  //   //clear all variable
  //   _image = null;
  //   alamat = "";
  //   id = "";
  //   longlat = "";
  //   //selfie = File(_image);
  //   setState(() {
  //     saveStatus();
  //     checkStatus = 1;
  //     loadHistoriAbsensi();
  //   });
  //   print("save berhasil check in berhasil");
  // }

  Future createCheckIn() async {
  // ✅ Validasi data kosong
  if (selfie == null ||
      !(await selfie.exists()) ||
      alamat.trim().isEmpty ||
      id.trim().isEmpty ||
      longlat.trim().isEmpty) {
    print("Data tidak lengkap untuk Check In.");
    
    // ✅ Tampilkan dialog error
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Gagal Check In"),
        content: Text("Data belum lengkap. Pastikan foto dan lokasi terisi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
    return;
  }

  // ✅ Kirim data kalau semua valid
  var stream = http.ByteStream(DelegatingStream.typed(selfie.openRead()));
  var length = await selfie.length();
  var multipartFile = http.MultipartFile(
    "image_checkin",
    stream,
    length,
    filename: path.basename(selfie.path),
  );

  var req = http.MultipartRequest('POST', Uri.parse(util.Api.urlCheckIn))
    ..headers['Content-Type'] = 'multipart/form-data'
    ..fields['id_user'] = '$id'
    ..fields['alamat_checkin'] = '$alamat'
    ..fields['longlat_checkin'] = '$longlat'
    ..files.add(multipartFile);

  await req.send();

  // ✅ Reset variabel
  _image = null;
  alamat = "";
  id = "";
  longlat = "";

  setState(() {
    saveStatus();
    checkStatus = 1;
    loadHistoriAbsensi();
  });

  print("Check in berhasil");
}

Future createCheckOut() async {
  // Validasi awal
  if (selfie == null ||
      !(await selfie.exists()) ||
      alamat.trim().isEmpty ||
      id.trim().isEmpty ||
      longlat.trim().isEmpty) {
    //"Data tidak lengkap untuk Check Out.");
    // Bisa tampilkan dialog error ke user juga
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Gagal Check Out"),
        content: Text("Data belum lengkap. Pastikan foto dan lokasi terisi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
    return;
  }

  // Kirim data jika valid
  var stream = http.ByteStream(DelegatingStream.typed(selfie.openRead()));
  var length = await selfie.length();
  var multipartFile = http.MultipartFile(
    "image_checkout",
    stream,
    length,
    filename: path.basename(selfie.path),
  );

  var req = http.MultipartRequest('POST', Uri.parse(util.Api.urlCheckIn))
    ..headers['Content-Type'] = 'multipart/form-data'
    ..fields['id_user'] = '$id'
    ..fields['alamat_checkout'] = '$alamat'
    ..fields['longlat_checkout'] = '$longlat'
    ..files.add(multipartFile);

  await req.send();

  // Clear variabel setelah berhasil
  _image = null;
  alamat = "";
  id = "";
  longlat = "";

  setState(() {
    removeStatus();
    checkStatus = 0;
    loadHistoriAbsensi();
  });

  print("Check out berhasil");
}

  // Future createCheckOut() async {
  //   // ignore: deprecated_member_use
  //   var stream = new http.ByteStream(DelegatingStream.typed(selfie.openRead()));
  //   var length = await selfie.length();
  //   var multipartFile = new http.MultipartFile("image_checkout", stream, length,
  //       filename: path.basename(selfie.path));

  //   var req = http.MultipartRequest('POST', Uri.parse(util.Api.urlCheckIn))
  //     ..headers['Content-Type'] = 'multipart/form-data'
  //     ..fields['id_user'] = '$id'
  //     ..fields['alamat_checkout'] = '$alamat'
  //     ..fields['longlat_checkout'] = '$longlat'
  //     ..files.add(multipartFile);
  //   await req.send();

  //   //clear all variable
  //   _image = null;
  //   alamat = "";
  //   id = "";
  //   longlat = "";
  //   //selfie = File(_image);
  //   setState(() {
  //     removeStatus();
  //     checkStatus = 0;
  //     loadHistoriAbsensi();
  //   });
  //   print("save berhasil check out berhasil");
  // }

  String extractSelectedAlamat(String alamat) {
    final parts = alamat.split(',').map((e) => e.trim()).toList();

    final selectedParts = [
      if (parts.length > 0) parts[0],
      if (parts.length > 3) parts[3],
      if (parts.length > 4) parts[4],
    ];

    return selectedParts.join(', ');
  }

  listHistoriAbsensi() => FutureBuilder(
        future: listAbsen,
        builder: (_, AsyncSnapshot<List<AbsenModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        DateTime konversiTgl = DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse("${snapshot.data[index].tglCheckin}");
                        tanggalCheckin = DateFormat('dd-MMM-yyyy HH:mm:ss')
                            .format(konversiTgl);

                        DateTime konversiTglOut =
                            DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                (snapshot.data[index].tglCheckout == null)
                                    ? "0000-00-00 00:00:00"
                                    : "${snapshot.data[index].tglCheckout}");
                        var tanggalCheckOut =
                            (snapshot.data[index].tglCheckout == null)
                                ? ""
                                : DateFormat('dd-MMM-yyyy HH:mm:ss')
                                    .format(konversiTglOut);

                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 5),
                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  width: 60,
                                  height: 50,
                                  child: new Image.asset(
                                    'assets/images/in.png',
                                    alignment: Alignment.centerLeft,
                                    width: 5,
                                    height: 2,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text('Check In : $tanggalCheckin'),
                                        Container(
                                          width: 250,
                                          child: Text(
                                            '${extractSelectedAlamat(snapshot.data[index].alamatCheckin).toString()}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        if (tanggalCheckOut != '')
                                          SizedBox(height: 10),
                                        if (tanggalCheckOut != '')
                                          Text('Check Out : $tanggalCheckOut'),
                                        Container(
                                          width: 250,
                                          child: (snapshot.data[index]
                                                      .alamatCheckout ==
                                                  null)
                                              ? Text('',
                                                  style: TextStyle(
                                                      color: Colors.grey))
                                              : Text(
                                                  '${extractSelectedAlamat(snapshot.data[index].alamatCheckout).toString()}',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                        ),
                                        if (tanggalCheckOut != '')
                                          SizedBox(height: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }));
            } else {
              return Column(children: [
                SizedBox(height: 50),
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 5),
                      Text("Anda belum memiliki catatan kehadiran."),
                    ])),
              ]);
            }
          }
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                spinkit,
                SizedBox(height: 10),
                Text("Mohon menunggu..."),
              ]));
        },
      );
}

Future sleep1() {
  return new Future.delayed(const Duration(seconds: 1), () => "1");
}

class CustomShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 140, size.width / 2, size.height - 80);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height - 30, size.width, size.height - 140);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
