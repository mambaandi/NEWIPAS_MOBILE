import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:image_picker/image_picker.dart';
import 'package:ipas_mobile/ui/list_cuti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'demo_screen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// ignore: must_be_immutable
class AddCuti extends StatefulWidget {
  //Inventaris editInventaris;
  AddCuti();

  @override
  _AddCutiState createState() => _AddCutiState();
}

class _AddCutiState extends State<AddCuti> {
  final formKey = GlobalKey<FormState>();

  TextEditingController tglMulaiCutiController = new TextEditingController();
  TextEditingController tglAkhirCutiController = new TextEditingController();
  TextEditingController lamaCutiController = new TextEditingController();
  TextEditingController sisaCutiController = new TextEditingController();

  final picker = ImagePicker();
  String _path;
  String branchID;
  String userID;
  var _rangeCount;
  String _rangeStart = '';
  String _rangeEnd = '';
  XFile pickedImage;
  int sisaCuti = 0;
  String idPegawai = '';
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future _simpanCuti() async {
    EasyLoading.show(status: 'Sedang menyimpan...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    branchID = preferences.getString("branch_id");
    userID = preferences.getString("id");

    final response = await http.post(
      Uri.parse(util.Api.urlCreateCuti),
      body: {
        'idPegawai': idPegawai.toString(),
        'tanggalMulai': tglMulaiCutiController.text,
        'tanggalAkhir': tglAkhirCutiController.text,
        'hariCuti': _rangeCount.toString(),
        'branchId': branchID.toString(),
        'dibuatOleh': userID.toString()
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("${data.toString()}");
      if (data['success'] == true) {
        EasyLoading.showSuccess("Data berhasil tersimpan!");
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ListCuti()));
      } else {
        EasyLoading.showError("Data gagal tersimpan!");
      }
    } else {
      //print("datanya adalah kosong");
      EasyLoading.showError("Data gagal tersimpan!");
    }
  }

  Future _cekSisaCuti() async {
    EasyLoading.show(status: 'Sedang mencari...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    branchID = preferences.getString("branch_id");
    userID = preferences.getString("id");

    final response = await http.post(
      Uri.parse(util.Api.urlListCuti),
      body: {
        'tanggal_akhir': tglAkhirCutiController.text,
        'branch_id': branchID.toString(),
        'dibuat_oleh': userID.toString(),
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        //print("data ${data.toString()}");
        // [FIX] 2024-09-26 - Fix type conversion error for idPegawai variable
        // [OLEH: Kilo Code]
        // [ALASAN: Mengubah integer ke string untuk menghindari type '_Smi' is not a subtype of type 'String'
        idPegawai = data.last['id_pegawai'].toString();
        sisaCuti = data.last['sisa_cuti'] - _rangeCount;
        sisaCutiController = TextEditingController(text: sisaCuti.toString());
      });
      //print("xx ${_rangeCount}");
      //print("yy ${data.last['sisa_cuti']}");
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError("Data tidak ditemukan!");
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _rangeStart =
            '${DateFormat('yyyy-MM-dd').format(args.value.startDate)}';
        _rangeEnd =
            '${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';

        int getDifferenceWithoutWeekends(DateTime startDate, DateTime endDate) {
          int nbDays = 0;
          DateTime currentDay = startDate;
          while (currentDay.isBefore(endDate)) {
            currentDay = currentDay.add(Duration(days: 1));
            if (currentDay.weekday != DateTime.saturday &&
                currentDay.weekday != DateTime.sunday) {
              nbDays += 1;
            }
          }
          return nbDays;
        }

        _rangeCount = getDifferenceWithoutWeekends(
                DateTime.parse(_rangeStart), DateTime.parse(_rangeEnd)) +
            1;
        tglMulaiCutiController = TextEditingController(text: _rangeStart);
        tglAkhirCutiController = TextEditingController(text: _rangeEnd);
        lamaCutiController =
            TextEditingController(text: _rangeCount.toString());
        _cekSisaCuti();
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

  List data = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          'Ajukan Cuti',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  if (_connectionStatus
                      .toString()
                      .contains('ConnectivityResult.none')) {
                    infoInternet();
                  } else {
                    if (sisaCuti < 0 || _rangeCount == null) {
                      EasyLoading.showError(
                          "Sisa cuti Anda tidak mencukupi\nuntuk pengajuan ini.");
                    } else {
                      _simpanCuti();
                    }
                  }
                },
                child: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 35,
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfDateRangePicker(
                enablePastDates: false,
                onSelectionChanged: _onSelectionChanged,
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: PickerDateRange(
                    DateTime.now().subtract(const Duration(days: 0)),
                    DateTime.now().add(const Duration(days: 3))),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Tanggal Mulai Cuti',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: tglMulaiCutiController,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: "yyyy-mm-dd",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Tanggal Selesai Cuti',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                controller: tglAkhirCutiController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: "yyyy-mm-dd",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Lama Cuti (hari)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Sisa Cuti (hari)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: TextFormField(
                        readOnly: true,
                        keyboardType: TextInputType.multiline,
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines:
                            1, // when user presses enter it will adapt to it
                        controller: lamaCutiController,
                        //validator: (value) => value.isEmpty ? 'Required' : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: new TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black38),
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      )),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      readOnly: true,
                      keyboardType: TextInputType.multiline,
                      minLines: 1, //Normal textInputField will be displayed
                      maxLines:
                          1, // when user presses enter it will adapt to it
                      controller: sisaCutiController,
                      //validator: (value) => value.isEmpty ? 'Required' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: new TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (DemoScreen(path: _path)),
      ),
    );
  }
}
