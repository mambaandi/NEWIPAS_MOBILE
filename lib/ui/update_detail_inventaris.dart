import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/model/inventaris.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class UpdateInventaris extends StatefulWidget {
  Inventaris dataInven;

  UpdateInventaris({@required this.dataInven});

  @override
  _UpdateInventarisState createState() => _UpdateInventarisState();
}

class _UpdateInventarisState extends State<UpdateInventaris> {
  final formKey = GlobalKey<FormState>();

  TextEditingController namaBarangController = new TextEditingController();
  TextEditingController jumlahBarangController = new TextEditingController();
  TextEditingController detailBarangController = new TextEditingController();
  String _selectedStatus = 'Baik';
  List data = [];

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    namaBarangController =
        TextEditingController(text: widget.dataInven.namaBarang);
    jumlahBarangController =
        TextEditingController(text: widget.dataInven.jumlahBarang);
    detailBarangController =
        TextEditingController(text: widget.dataInven.infoBarang);
    _selectedStatus = widget.dataInven.infoBarang;
    getAllStatus();
    super.initState();
  }

  // Http post request
  Future editInventaris() async {
    EasyLoading.showInfo("Data sedang disimpan...");
    var req = http.MultipartRequest('POST',
        Uri.parse('https://inovbaba.com/inventory/update_inventaris.php'))
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['id_barang'] = '${widget.dataInven.idBarang}'
      ..fields['nama_barang'] = '${namaBarangController.text}'
      ..fields['jumlah_barang'] = '${jumlahBarangController.text}'
      ..fields['informasi_barang'] = '${_selectedStatus.toString()}'
      ..fields['note'] = '${detailBarangController.text}';

    await req.send();

    return Future.value(true);
  }

  Future getAllStatus() async {
    var url = Uri.parse('https://inovbaba.com/inventory/status.php');
    var response = await http.get(url);
    var jsonBody = response.body;
    var jsonData = json.decode(jsonBody);

    setState(() {
      data = jsonData;
    });

    return 'success';
  }

  void _onConfirm(context) async {
    var response = await editInventaris();
    if (response) {
      Navigator.pop(context, true);
    } else {
      var snackBar = SnackBar(content: Text('Data gagal diubah'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Inventaris', style: TextStyle(color: Colors.black)),
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: Color(0xFFC2DD5F),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text('Nama Barang'),
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: namaBarangController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC2DD5F)),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Jumlah Unit'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: jumlahBarangController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC2DD5F)),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Status'),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text('Baik'), // Not necessary for Option 1
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value.toString();
                      print(value);
                    });
                  },
                  items: data.map((list) {
                    return DropdownMenuItem(
                      child: Text(list['nama_status']),
                      value: list['nama_status'].toString(),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text('Detail Barang'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: detailBarangController,
                validator: (value) => value.isEmpty ? 'Required' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintStyle: new TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC2DD5F)),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFFC2DD5F),
                              Color(0xFF818550),
                            ]),
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFF6078ea).withOpacity(.3),
                                  offset: Offset(0.0, 8.0),
                                  blurRadius: 8.0)
                            ]),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              SizedBox(
                                width: 2,
                              ),
                              Text("SAVE",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Poppins-Bold",
                                      fontSize: 18,
                                      letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        _onConfirm(context);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
