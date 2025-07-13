import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/model/reimburse.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:ipas_mobile/model/util.dart' as util;
import "package:async/async.dart";
import 'package:image_picker/image_picker.dart';

import '../currency.dart';
import 'demo_screen.dart';

// ignore: must_be_immutable
class AddDetailReimb extends StatefulWidget {
  String noReimb;
  int total;

  AddDetailReimb({@required this.noReimb, @required this.total});

  @override
  _AddDetailReimbState createState() => _AddDetailReimbState();
}

class _AddDetailReimbState extends State<AddDetailReimb> {
  final ScrollController _scroll = ScrollController();
  final itemSize = 330.0;
  final form = GlobalKey<FormState>();
  List<ListItem> _reimburse = [];
  List<File> _image = [];
  final picker = ImagePicker();
  int indexItem = 0;
  String _path;
  // final dataKey = new GlobalKey();
  var _namaBarang = [];
  var _biayaReimburse = [];
  XFile pickedImage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        actions: <Widget>[
          indexItem > 0
              ? Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      if (form.currentState.validate() &&
                          (_image[indexItem - 1] != null)) {
                        form.currentState.save();
                        _onConfirm();
                      } else {
                        EasyLoading.showError(
                            'Anda belum memilih foto invoice/bon');
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
          'Add Item Reimburse',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: form,
          child: Column(
            children: [
              indexItem > 0
                  ? Expanded(
                      child: ListView.builder(
                          controller: _scroll,
                          itemExtent: itemSize,
                          shrinkWrap: true,
                          itemCount: _reimburse.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _formItem(index);
                          }),
                    )
                  : SizedBox(height: 250),
              indexItem > 0
                  ? Text('')
                  : Text(
                      'Klik tombol dibawah ini untuk menambah item reimburse Anda.',
                      textAlign: TextAlign.center),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton.icon(
                          onPressed: () {
                            var s = indexItem - 1;
                            if (indexItem > 0) {
                              if (form.currentState.validate() &&
                                  (_image[s] != null)) {
                                _addItemList();
                                _moveDown();
                              } else {
                                EasyLoading.showError(
                                    'Anda belum memilih foto invoice/bon');
                              }
                            } else {
                              _addItemList();
                              _moveDown();
                            }
                          },
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Color(0xFF000000)),
                              side: MaterialStateProperty.all(BorderSide(
                                color: Colors.deepPurple.shade300,
                                width: 2,
                              ))),
                          icon: Icon(Icons.add),
                          label: Text('Tambah Data')),
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
                                    foregroundColor: MaterialStateProperty.all(
                                        Color(0xFF000000)),
                                    side: MaterialStateProperty.all(BorderSide(
                                      color: Colors.deepPurple.shade300,
                                      width: 5,
                                    ))),
                                icon: Icon(Icons.remove),
                                label: indexItem > 0
                                    ? Text('Hapus Itemx')
                                    : Text('')),
                          )
                        : Text(''),
                  ]),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formItem(int index) {
    _namaBarang.add(TextEditingController());
    _biayaReimburse.add(TextEditingController());
    var indexyu = index + 1;
    _reimburse[index].idDetailReimburse = indexyu;
    return Stack(
      // key: dataKey,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            // width: 350,
            height: 350,
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.deepPurple.shade300, width: 1.0),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _namaBarang[index],
                  onSaved: (String value) {
                    if (value.isNotEmpty) {
                      _reimburse[index].namaReimburse = value;
                    }
                  },
                  validator: (value) => value.isEmpty ? 'Required' : null,
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyFormat(maxDigits: 10),
                  ],
                  maxLength: 10,
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Foto',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Row(children: [
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
                          : GestureDetector(
                              onTap: () {
                                open(context);
                              },
                              child: Image.file(
                                _image[index],
                              )),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 12,
          child: Container(
              color: Colors.white, child: Text('Item #${index + indexyu}')),
        ),
      ],
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
      // _image.clear();
    });
  }

  _moveUp() {
    _scroll.animateTo(_scroll.offset - itemSize,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  _moveDown() {
    _scroll.animateTo(_scroll.offset + itemSize,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  void open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (DemoScreen(path: _path)),
      ),
    );
  }

  _onConfirm() async {
    var response = await _createItemReimb();
    if (response) {
      Navigator.pop(context, true);
      EasyLoading.showSuccess('Berhasil disimpan!');
    } else {
      EasyLoading.showError('Gagal disimpan!');
    }
  }

  Future _createItemReimb() async {
    double totSelesai = 0.0;
    double persenSelesai = 0.0;
    EasyLoading.showInfo("Sedang memproses...");
    var nomorRembus = widget.noReimb;
    var totalRembus = _reimburse
        .map((e) => e.biaya)
        .toList()
        .reduce((value, element) => value + element);
    var semuaTotalGabungan = totalRembus + widget.total;
    for (int i = 0; i < _reimburse.length; i++) {
      var stream =
          // ignore: deprecated_member_use
          new http.ByteStream(DelegatingStream.typed(_image[i].openRead()));
      var length = await _image[i].length();
      var multipartFile = new http.MultipartFile("image", stream, length,
          filename: path.basename(_image[i].path));

      var req =
          http.MultipartRequest('POST', Uri.parse(util.Api.urlUpdateReimburse))
            ..headers['Content-Type'] = 'multipart/form-data'
            ..fields['total_reimburse'] = '$semuaTotalGabungan'
            ..fields['nomor_reimburse'] = '$nomorRembus';
      await req.send();

      var requu = http.MultipartRequest(
          'POST', Uri.parse(util.Api.urlInsertDetailReimburse))
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['nomor_reimb'] = '$nomorRembus'
        ..fields['biaya'] = '${_reimburse[i].biaya}'
        ..fields['item_reimburse'] = '${_reimburse[i].namaReimburse}'
        ..files.add(multipartFile);

      await requu.send();
      totSelesai = (i / 100) * (100 / _reimburse.length);
      persenSelesai = totSelesai * 100;
      EasyLoading.showProgress(totSelesai,
          status: '${persenSelesai.toStringAsFixed(0)}%');
    }
    return Future.value(true);
  }
}
