import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:ipas_mobile/model/reimburse_model.dart';
import 'package:ipas_mobile/ui/add_detail_reim.dart';
import 'package:intl/intl.dart';

import '../currency.dart';

class UpdateReimburse extends StatefulWidget {
  final Map<String, dynamic> detailRemb;

  UpdateReimburse({@required this.detailRemb});

  @override
  _UpdateReimburseState createState() => _UpdateReimburseState();
}

class _UpdateReimburseState extends State<UpdateReimburse> {
  final form = GlobalKey<FormState>();
  ReimburseModel dataRembus;

  List<String> idItemHapus = [];
  final uang = NumberFormat('#,###', "id");

  @override
  void initState() {
    dataRembus = ReimburseModel.fromJson(widget.detailRemb);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          'Form Reimbursement',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_outlined,
                size: 30, color: Colors.white),
            onPressed: () async {
              var res = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return AddDetailReimb(
                      noReimb: dataRembus.nomorReimburse,
                      total: dataRembus.detailReimburse
                          .map((e) => int.parse(e.biaya))
                          .toList()
                          .reduce((value, element) => value + element));
                }),
              );

              if (res != null && res) {
                Navigator.pop(context, res);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: form,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: dataRembus.detailReimburse.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _formItem(index);
                    }),
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
                              Colors.deepPurple.shade700,
                              Colors.deepPurple.shade300,
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
                              Text("Save",
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
                        if (form.currentState.validate()) {
                          form.currentState.save();
                          _onConfirm(context);
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formItem(int index) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            width: MediaQuery.of(context).size.width - 20,
            height: 300,
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.deepPurple.shade300, width: 1.0),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // hapus data dari list

                      print('${dataRembus.detailReimburse[index].toJson()}');
                      idItemHapus.add(
                          dataRembus.detailReimburse[index].idDetailReimburse);
                      dataRembus.detailReimburse.removeAt(index);

                      print('$idItemHapus');
                      // reload halaman
                      setState(() {});
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Item Reimburse',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  // initialValue: dataRembus.detailReimburse[index].itemReimburse,
                  keyboardType: TextInputType.multiline,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 2, // when user presses enter it will adapt to it
                  controller: TextEditingController(
                      text:
                          '${dataRembus.detailReimburse[index].itemReimburse}'),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      dataRembus.detailReimburse[index].itemReimburse = value;
                    }
                  },
                  validator: (value) => value.isEmpty ? 'Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: "Nama barang atau bon..",
                    hintStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Biaya',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  // initialValue: dataRembus.detailReimburse[index].biaya,
                  controller: TextEditingController(
                      // text: '${dataRembus.detailReimburse[index].biaya}'),
                      text:
                          '${uang.format(int.parse(dataRembus.detailReimburse[index].biaya))}'),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value = value.replaceAll(',', '');
                      value = value.replaceAll('.', '');
                      dataRembus.detailReimburse[index].biaya = value;
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
                    hintText: "Contoh: 1000",
                    hintStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 12,
          child:
              Container(color: Colors.white, child: Text('Item #${index + 1}')),
        ),
      ],
    );
  }

  void _onConfirm(context) async {
    var response = await _updateItemReimburse();
    if (response) {
      Navigator.pop(context, true);
      EasyLoading.showSuccess('Berhasil disimpan!');
    } else {
      EasyLoading.showError('Gagal disimpan!');
    }
  }

  Future _updateItemReimburse() async {
    double totSelesai = 0.0;
    double persenSelesai = 0.0;
    EasyLoading.showInfo("Sedang memproses...");
    var nomorRembus = dataRembus.nomorReimburse;
    var totalRembus = dataRembus.detailReimburse
        .map((e) => int.parse(e.biaya))
        .toList()
        .reduce((value, element) => value + element);

    var req =
        http.MultipartRequest('POST', Uri.parse(util.Api.urlUpdateReimburse))
          ..headers['Content-Type'] = 'multipart/form-data'
          ..fields['total_reimburse'] = '$totalRembus'
          ..fields['nomor_reimburse'] = '$nomorRembus';
    await req.send();

    for (int i = 0; i < dataRembus.detailReimburse.length; i++) {
      var requ = http.MultipartRequest(
          'POST', Uri.parse(util.Api.urlUpdateDetailReimburse))
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['id_detail_reimburse'] =
            '${dataRembus.detailReimburse[i].idDetailReimburse}'
        ..fields['biaya'] = '${dataRembus.detailReimburse[i].biaya}'
        ..fields['item_reimburse'] =
            '${dataRembus.detailReimburse[i].itemReimburse}';

      await requ.send();
      totSelesai = (i / 100) * (100 / dataRembus.detailReimburse.length);
      persenSelesai = totSelesai * 100;
      EasyLoading.showProgress(totSelesai,
          status: '${persenSelesai.toStringAsFixed(0)}%');
    }

    idItemHapus.forEach((idItem) {
      var requu =
          http.MultipartRequest('POST', Uri.parse(util.Api.urlDelItemReimburse))
            ..headers['Content-Type'] = 'multipart/form-data'
            ..fields['id_detail_reimburse'] = '$idItem';
      requu.send();
    });

    return Future.value(true);
  }
}
