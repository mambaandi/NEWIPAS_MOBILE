import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/model/reimburse.dart';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/widgets/color_palette.dart';
import 'package:path/path.dart' as path;
import 'package:ipas_mobile/model/util.dart' as util;
import "package:async/async.dart";
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency.dart';
import 'demo_screen.dart';

class AddReimburse extends StatefulWidget {
  @override
  _AddReimburseState createState() => _AddReimburseState();
}

class _AddReimburseState extends State<AddReimburse> {
  final ScrollController _scroll = ScrollController();
  final itemSize = 330.0;
  final form = GlobalKey<FormState>();
  List<ListItem> _reimburse = [];
  List<File> _image = [];
  final picker = ImagePicker();
  String _path;
  int indexItem = 0;
  // final dataKey = new GlobalKey();
  var _namaBarang = [];
  var _biayaReimburse = [];
  String branchID;
  String userID;
  String idPegawai;
  XFile pickedImage;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  Future choiceImage(int index) async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 60);
    _path = (pickedImage != null) ? pickedImage.path : "";

    setState(() {
      if (pickedImage != null) {
        _image[index] = File(pickedImage.path);
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        actions: <Widget>[
          indexItem > 0
              ? Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_connectionStatus
                          .toString()
                          .contains('ConnectivityResult.none')) {
                        infoInternet();
                      } else {
                        if (form.currentState.validate() &&
                            (_image[indexItem - 1] != null)) {
                          form.currentState.save();
                          _onConfirm();
                        } else {
                          EasyLoading.showError(
                              'Anda belum memilih\nfoto invoice/bon');
                        }
                      }
                    },
                    child: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 30,
                    ),
                  ))
              : Text(''),
        ],
        title: Text(
          'Form Reimburse',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Form(
          key: form,
          child: Column(
            children: [
              indexItem > 0
                  ? Expanded(
                      child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: ListView.builder(
                          controller: _scroll,
                          itemExtent: itemSize,
                          shrinkWrap: true,
                          itemCount: _reimburse.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _formItem2(index);
                          }),
                    ))
                  : SizedBox(height: 250),
              indexItem > 0
                  ? Text('')
                  : Text(
                      'Klik tombol dibawah ini untuk memulai\npengajuan reimburse Anda.\n',
                      textAlign: TextAlign.center),
              //SizedBox(height: 20),

              Container(
                  height: 60.0,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: Colors.grey.shade300,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: OutlinedButton.icon(
                                  onPressed: () {
                                    var s = indexItem - 1;
                                    FocusScope.of(context).enclosingScope;
                                    if (indexItem > 0) {
                                      if (form.currentState.validate() &&
                                          (_image[s] != null)) {
                                        _addItemList();
                                        _moveDown();
                                      } else {
                                        EasyLoading.showError(
                                            'Anda belum memilih\nfoto invoice/bon');
                                      }
                                    } else {
                                      _addItemList();
                                      _moveDown();
                                    }
                                  },
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                      side:
                                          MaterialStateProperty.all(BorderSide(
                                        color: Colors.green.shade600,
                                        width: 2,
                                      ))),
                                  icon: Icon(Icons.add,
                                      color: Colors.green.shade600),
                                  label: indexItem > 0
                                      ? Text(
                                          'Add Item',
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                          ),
                                        )
                                      : Text('Buat Form Baru')),
                            ),
                            SizedBox(width: 10),
                            indexItem > 0
                                ? Align(
                                    alignment: Alignment.center,
                                    child: OutlinedButton.icon(
                                        onPressed: () {
                                          FocusScope.of(context).enclosingScope;
                                          if (indexItem > 0) {
                                            _cancelItemList();
                                            _moveUp();
                                          } else {
                                            _cancelItemList();
                                            _moveUp();
                                          }
                                        },
                                        style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFF000000)),
                                            side: MaterialStateProperty.all(
                                                BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ))),
                                        icon: Icon(Icons.remove,
                                            color: Colors.red),
                                        label: indexItem > 0
                                            ? Text(
                                                'Delete Item',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )
                                            : Text('')),
                                  )
                                : Text(''),
                          ]))),
              //SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formItem2(int index) {
    var indexyu = index + 1;
    _namaBarang.add(TextEditingController());
    _biayaReimburse.add(TextEditingController());
    _reimburse[index].idDetailReimburse = indexyu;
    return Stack(
      // key: dataKey,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
            height: 340,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: ColorPalette.temaColor, width: 1.0),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _namaBarang[index],
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.multiline,
                  minLines: 2, //Normal textInputField will be displayed
                  maxLines: 2, // when user presses enter it will adapt to it
                  onSaved: (String value) {
                    if (value.isNotEmpty) {
                      value = value.toUpperCase();
                      _reimburse[index].namaReimburse = value;
                    }
                  },
                  validator: (String value) =>
                      value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Item Reimburse',
                    hintText: "Nama barang atau bon..",
                    hintStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _biayaReimburse[index],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value = value.replaceAll(',', '');
                      value = value.replaceAll('.', '');
                      _reimburse[index].biaya = double.parse(value);
                    }
                  },
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyFormat(maxDigits: 10),
                  ],
                  validator: (value) => value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Biaya',
                    hintText: "Contoh: 1000",
                    hintStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 65,
                        height: 65,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black38),
                            ),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.black38,
                              size: 35,
                            ),
                            onPressed: () {
                              choiceImage(index);
                            }),
                      ),
                    ),
                    SizedBox(width: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 150,
                        height: 100,
                        child: _image[index] == null
                            ? Text(
                                '\n\nPilih foto invoice/bon yang akan diupload',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic),
                              )
                            // : Image.file(_image[index], fit: BoxFit.cover),
                            : GestureDetector(
                                onTap: () {
                                  open(context);
                                },
                                child: Image.file(
                                  _image[index],
                                )),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
                color: Colors.white, child: Text('Items #${index + 1}'))),
      ],
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

  void _addItemList() {
    setState(() {
      _reimburse.add(ListItem());
      _image.add(null);
      indexItem = indexItem + 1;
    });
  }

  void _cancelItemList() {
    setState(() {
      indexItem = indexItem - 1;
      _reimburse.removeAt(indexItem);
      //_image.clear();
    });
  }

  _moveDown() {
    _scroll.animateTo(_scroll.offset + itemSize,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
    if (!_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
      //_scroll.jumpTo(50.0);
    }
  }

  _moveUp() {
    _scroll.animateTo(_scroll.offset - itemSize,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  _onConfirm() async {
    var response = await _createItemReimburse();
    if (response) {
      Navigator.pop(context, true);
      EasyLoading.showSuccess('Berhasil disimpan!');
    } else {
      EasyLoading.showError('Gagal disimpan!');
    }
  }

  Future _createItemReimburse() async {
    double totSelesai = 0.0;
    double persenSelesai = 0.0;
    EasyLoading.showInfo("Sedang memproses...");
    var nomorRembus = DateTime.now().microsecondsSinceEpoch.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    branchID = preferences.getString("branch_id");
    userID = preferences.getString("id");
    idPegawai = preferences.getString("id_pegawai");
    var totalRembus = _reimburse
        .map((e) => e.biaya)
        .toList()
        .reduce((value, element) => value + element);
    var req =
        http.MultipartRequest('POST', Uri.parse(util.Api.urlInsertReimburse))
          ..headers['Content-Type'] = 'multipart/form-data'
          ..fields['total_reimburse'] = '$totalRembus'
          ..fields['nomor_reimburse'] = '$nomorRembus'
          ..fields['branch_id'] = branchID.toString()
          ..fields['user_id'] = userID.toString()
          ..fields['id_pegawai'] = idPegawai.toString();
    await req.send();

    for (int i = 0; i < _reimburse.length; i++) {
      var stream =
          // ignore: deprecated_member_use
          new http.ByteStream(DelegatingStream.typed(_image[i].openRead()));
      var length = await _image[i].length();
      var multipartFile = new http.MultipartFile("image", stream, length,
          filename: path.basename(_image[i].path));
      var requ = http.MultipartRequest(
          'POST', Uri.parse(util.Api.urlInsertDetailReimburse))
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['nomor_reimb'] = '$nomorRembus'
        ..fields['biaya'] = '${_reimburse[i].biaya}'
        ..fields['item_reimburse'] = '${_reimburse[i].namaReimburse}'
        ..files.add(multipartFile);

      await requ.send();
      totSelesai = (i / 100) * (100 / _reimburse.length);
      persenSelesai = totSelesai * 100;
      EasyLoading.showProgress(totSelesai,
          status: '${persenSelesai.toStringAsFixed(0)}%');
    }
    return Future.value(true);
  }
}
