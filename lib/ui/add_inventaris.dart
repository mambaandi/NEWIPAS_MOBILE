import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:image_picker/image_picker.dart';
import 'package:ipas_mobile/widgets/color_palette.dart';
import 'package:path/path.dart';
import "package:async/async.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ipas_mobile/model/inventaris.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'demo_screen.dart';

// ignore: must_be_immutable
class AddInventaris extends StatefulWidget {
  Inventaris editInventaris;
  AddInventaris({@required this.editInventaris});

  @override
  _AddInventarisState createState() => _AddInventarisState();
}

class _AddInventarisState extends State<AddInventaris> {
  final formKey = GlobalKey<FormState>();

  TextEditingController namaBarangController = new TextEditingController();
  TextEditingController jumlahBarangController = new TextEditingController();
  TextEditingController detailBarangController = new TextEditingController();

  File _image;
  final picker = ImagePicker();
  String _path;
  String branchID;
  String userID;
  XFile pickedImage;

  Future choiceImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 60);
    _path = (pickedImage != null) ? pickedImage.path : "";
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  Future _createInventaris() async {
    EasyLoading.showInfo("Data sedang disimpan...");
    // ignore: deprecated_member_use
    var stream = new http.ByteStream(DelegatingStream.typed(_image.openRead()));
    var length = await _image.length();
    var request = new http.MultipartRequest(
        "POST", Uri.parse(util.Api.urlInsertInventory));

    var multipartFile = new http.MultipartFile("image", stream, length,
        filename: basename(_image.path));

    SharedPreferences preferences = await SharedPreferences.getInstance();
    branchID = preferences.getString("branch_id");
    userID = preferences.getString("id");
    request.files.add(multipartFile);
    request.fields['nama_barang'] = namaBarangController.text;
    request.fields['jumlah_barang'] = jumlahBarangController.text;
    request.fields['informasi_barang'] = _selectedStatus.toString();
    request.fields['note'] = detailBarangController.text;
    request.fields['branch_id'] = branchID.toString();
    request.fields['user_id'] = userID.toString();

    var respond = await request.send();
    if (respond.statusCode == 200) {
      EasyLoading.showSuccess('Berhasil disimpan!');
    } else {
      EasyLoading.showError('Gagal disimpan!');
    }
  }

  // Http post request
  Future editInventaris() async {
    var req =
        http.MultipartRequest('POST', Uri.parse(util.Api.urlUpdateInventory))
          ..headers['Content-Type'] = 'multipart/form-data'
          ..fields['id_barang'] = '${widget.editInventaris.idBarang}'
          ..fields['nama_barang'] = '${namaBarangController.text}'
          ..fields['jumlah_barang'] = '${jumlahBarangController.text}'
          ..fields['informasi_barang'] = '${_selectedStatus.toString()}'
          ..fields['note'] = '${detailBarangController.text}';

    var respondEdit = await req.send();
    if (respondEdit.statusCode == 200) {
      EasyLoading.showSuccess('Berhasil disimpan!');
    } else {
      EasyLoading.showError('Gagal disimpan!');
    }
    return Future.value(true);
  }

  void _onConfirm(context) async {
    await _createInventaris();
    Navigator.pop(context, true);
  }

  void _onUpdateConfirm(context) async {
    var response = await editInventaris();
    if (response) {
      Navigator.pop(context, true);
    } else {
      var snackBar = SnackBar(content: Text('Data gagal diubah'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List data = [];
  int _selectedStatus = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (widget.editInventaris.toString() != 'null') {
      namaBarangController =
          TextEditingController(text: widget.editInventaris.namaBarang);
      jumlahBarangController =
          TextEditingController(text: widget.editInventaris.jumlahBarang);
      detailBarangController =
          TextEditingController(text: widget.editInventaris.noteBarang);
      _selectedStatus = int.parse(widget.editInventaris.infoBarang);
      // _pilStatus = 1;
    }

    super.initState();
  }

  List<String> _pilStatus = [
    'Dikirim',
    'Diterima',
    'Pengembalian',
    'Rusak',
  ];

  Widget _buildChipsStatus(context) {
    List<Widget> chips = [];
    for (int i = 0; i < _pilStatus.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedStatus == i,
        label: Text(_pilStatus[i],
            style: _selectedStatus == i
                ? TextStyle(color: Colors.white)
                : TextStyle(color: Colors.black)),
        avatar: _selectedStatus == i
            ? Icon(Icons.check, color: Colors.white)
            : null,
        pressElevation: 5,
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
        backgroundColor: Colors.transparent,
        selectedColor: ColorPalette.temaColor,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedStatus = i;
              print("$i " + _pilStatus[i]);
            }
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), child: choiceChip));
    }
    return Row(
      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          (widget.editInventaris.toString() == 'null')
              ? 'Tambah Data Inventaris '
              : 'Edit Data Inventaris',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  if (widget.editInventaris.toString() == 'null') {
                    if (formKey.currentState.validate()) {
                      if (_image == null) {
                        EasyLoading.showError('Foto barang harus disertakan!');
                      } else {
                        _onConfirm(context);
                      }
                    }
                  } else {
                    _onUpdateConfirm(context);
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
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Nama Barang',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: namaBarangController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Contoh: meja, kursi, laptop...",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Jumlah Unit',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: jumlahBarangController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 4,
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: "isi dengan angka...",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Status',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Container(
                height: 50.0,
                child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: _buildChipsStatus(context),
                      ),
                    ]),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Detail Barang',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 1, //Normal textInputField will be displayed
                maxLines: 5, // when user presses enter it will adapt to it
                controller: detailBarangController,
                //validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: "Keterangan lainnya jika ada...",
                  hintStyle: new TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Foto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              (widget.editInventaris.toString() == 'null')
                  ? Row(children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: 65,
                          height: 65,
                          child: OutlinedButton(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.black12,
                              size: 35,
                            ),
                            onPressed: () {
                              choiceImage();
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 150,
                          height: 100,
                          child: _image == null
                              ? Text(
                                  '\n\nPilih foto barang yang akan diupload',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    open(context);
                                  },
                                  child: Image.file(
                                    _image,
                                  )),
                        ),
                      ),
                    ])
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        '${util.Api.baseURL}/foto_barang/${widget.editInventaris.image}',
                        width: 250.0,
                        fit: BoxFit.cover,
                      ),
                    )
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
