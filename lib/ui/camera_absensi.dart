import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:ipas_mobile/main.dart';

class CameraAbsensi extends StatefulWidget {
  @override
  _CameraAbsensiState createState() => _CameraAbsensiState();
}

class _CameraAbsensiState extends State<CameraAbsensi> {
  // camera
  int initialCamera = 1;
  CameraController controller;
  bool cekFlash = false;
  String alamat = "";
  String name = "";
  String id = "";
  String longlat = "";

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("name");
      id = preferences.getString("id");
    });
  }

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(cameras[initialCamera], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controller.setFlashMode(FlashMode.off);
      });
    });
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: CameraPreview(
              controller,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            padding: EdgeInsets.all(32.0),
            child: StreamBuilder<LatLongPosition>(
                stream: TrustLocation.onChange,
                builder: (context, AsyncSnapshot<LatLongPosition> snapshot1) {
                  if (snapshot1.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Clock In',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        /*Text(
                          'Nama : $name',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white),
                        ),*/
                        FutureBuilder<List<Placemark>>(
                            future: placemarkFromCoordinates(
                                double.parse(snapshot1.data.latitude),
                                double.parse(snapshot1.data.longitude)),
                            builder: (context,
                                AsyncSnapshot<List<Placemark>> snapshot2) {
                              if (snapshot2.hasData) {
                                if (snapshot2.data.length > 0) {
                                  longlat =
                                      '${snapshot1.data.latitude}, ${snapshot1.data.longitude}';
                                  alamat =
                                      '${snapshot2.data[0].street}, RT ${snapshot2.data[0].name}, ${snapshot2.data[0].subLocality}, ${snapshot2.data[0].locality}, ${snapshot2.data[0].subAdministrativeArea}, ${snapshot2.data[0].postalCode}';
                                  return Text(
                                    'Lokasi : $alamat',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        .copyWith(color: Colors.white),
                                  );
                                }
                                return Container();
                              }
                              return Container();
                            }),
                      ],
                    );
                  }
                  return Center(
                      child: Text('Loading...',
                          style: TextStyle(color: Colors.white)));
                }),
          ),
          initialCamera == 0
              ? cekFlash
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          cekFlash = false;
                          controller.setFlashMode(FlashMode.off);
                        });
                      },
                      icon: Icon(Icons.flash_on, color: Colors.white),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          cekFlash = true;
                          controller.setFlashMode(FlashMode.always);
                        });
                      },
                      icon: Icon(Icons.flash_off, color: Colors.white),
                    )
              : Text(''),
          Row(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 56.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              SizedBox(width: 95),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 56.0,
                    ),
                    onPressed: () async {
                      EasyLoading.show(status: 'Please wait...');
                      XFile x = await controller.takePicture();
                      List<String> dataCheckinFoto = [
                        alamat,
                        x.path,
                        id,
                        longlat
                      ];
                      Navigator.pop(context, dataCheckinFoto);
                      EasyLoading.dismiss();
                    },
                  ),
                ),
              ),
              SizedBox(width: 95),
              /*Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 56.0,
                    ),
                    onPressed: () {
                      if (cameras.length > 1) {
                        setState(() {
                          initialCamera = initialCamera == 1 ? 0 : 1;
                          controller = CameraController(
                              cameras[initialCamera], ResolutionPreset.max);
                          controller.initialize().then((_) {
                            if (!mounted) {
                              return;
                            }
                            setState(() {});
                          });
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('No secondary camera found'),
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    },
                  ),
                ),
              ),*/
            ],
          )
        ],
      )),
      // bottomNavigationBar: ,
    );
  }

  @override
  Future<void> dispose() async {
    //controller.dispose();
    await controller.dispose();
    super.dispose();
  }
}
