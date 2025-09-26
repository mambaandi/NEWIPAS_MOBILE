import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/model/reimburse_model.dart';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:ipas_mobile/model/util.dart';
import 'package:ipas_mobile/ui/update_detail_reimburse.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_reimburse.dart';
import 'home_page.dart';

class ListReimb extends StatefulWidget {
  @override
  _ListReimbState createState() => _ListReimbState();
}

class _ListReimbState extends State<ListReimb> {
  Future<List<ReimburseModel>> listRemburse = Future.value([]);
  List<String> idReimHapus = [];
  final uang = NumberFormat('#,###', "id");
  String userid = "";
  String name = "";
  String branchID = "";
  String idPegawai = "";
  int ambilStatus;

  List<String> _pilStatus = [
    'Menunggu review',
    'Disetujui',
    'Ditolak',
    'Meminta revisi',
    'Draf'
  ];

  @override
  void initState() {
    getPref();
    super.initState();
  }

  loadData() {
    if (userid != null && userid.isNotEmpty) {
      fetchReimburse(userid).then((value) {
        if (value != null && value.isNotEmpty) {
          setState(() {
            listRemburse = Future.value(value);
          });
        }
      });
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("name") ?? "";
      userid = preferences.getString("id") ?? "";
      branchID = preferences.getString("branch_id") ?? "";
      ambilStatus = preferences.getInt('status') ?? 0;
      idPegawai = preferences.getString("id_pegawai") ?? "";
      print("ID Pegawai=$idPegawai");
      print("name=$name");
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: IconButton(
            onPressed: () {},
            icon: Icon(Icons.assignment),
          ),
        ),
        title: Text(
          'Reimbursement',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: FutureBuilder(
            future: listRemburse,
            builder: (_, AsyncSnapshot<List<ReimburseModel>> snapshot) {
              //cek data ada atau tidak
              if (snapshot.hasData) {
                // cek jumlah dalam list lebih dari 0?
                if (snapshot.data.length > 0) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Card(
                                    color: Colors.grey.shade200,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      tileColor: Colors.grey.shade200,
                                      leading: Hero(
                                        tag: snapshot.data[index].idReimburse,
                                        child: CircleAvatar(
                                          radius: 16.0,
                                          child: new Text(
                                            '${index + 1}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          //backgroundImage: NetworkImage(user.image),
                                        ),
                                      ),
                                      title: Text(
                                        'No. ${snapshot.data[index].nomorReimburse}',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Total Rp. ${uang.format(int.parse(snapshot.data[index].totalReimburse))}'),
                                            SizedBox(height: 5),
                                            badges.Badge(
                                              position:
                                                  badges.BadgePosition.topEnd(
                                                      top: -10, end: -12),
                                              showBadge: true,
                                              ignorePointer: false,
                                              onTap: () {},
                                              badgeContent: Text(
                                                  '${_pilStatus[int.parse(snapshot.data[index].statusReimburse)]}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13)),
                                              badgeStyle: badges.BadgeStyle(
                                                shape: badges.BadgeShape.square,
                                                badgeColor: int.parse(snapshot
                                                            .data[index]
                                                            .statusReimburse) ==
                                                        0
                                                    ? Colors.amber.shade600
                                                    : int.parse(snapshot
                                                                .data[index]
                                                                .statusReimburse) ==
                                                            1
                                                        ? Colors.green.shade400
                                                        : int.parse(snapshot
                                                                    .data[index]
                                                                    .statusReimburse) ==
                                                                2
                                                            ? Colors.red
                                                            : Colors
                                                                .grey.shade500,
                                                padding: EdgeInsets.all(7),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                elevation: 0,
                                              ),
                                            ),
                                            (snapshot.data[index]
                                                        .keteranganTolak ==
                                                    "")
                                                ? Text('')
                                                : Text(
                                                    'Note: ${snapshot.data[index].keteranganTolak}'),
                                          ]),
                                      isThreeLine: true,
                                      dense: false,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          int.parse(snapshot.data[index]
                                                      .statusReimburse) ==
                                                  1
                                              ? Text('')
                                              : IconButton(
                                                  icon:
                                                      Icon(Icons.edit_outlined),
                                                  onPressed: () async {
                                                    var res =
                                                        await Navigator.of(
                                                                context)
                                                            .push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                        return UpdateReimburse(
                                                            detailRemb: snapshot
                                                                .data[index]
                                                                .toJson());
                                                      }),
                                                    );

                                                    if (res != null && res) {
                                                      loadData();
                                                    }
                                                  },
                                                ),
                                          int.parse(snapshot.data[index]
                                                      .statusReimburse) ==
                                                  1
                                              ? Icon(Icons.check)
                                              : IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          title:
                                                              Column(children: [
                                                            const Text('Alert'),
                                                            Divider(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400)
                                                          ]),
                                                          content: Text(
                                                              'Apakah form reimburse No. ${snapshot.data[index].nomorReimburse} akan dihapus?'),
                                                          actions: <Widget>[
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  'Tidak'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Ya, Hapus!'),
                                                              onPressed:
                                                                  () async {
                                                                var req = http
                                                                    .MultipartRequest(
                                                                        'POST',
                                                                        Uri.parse(util
                                                                            .Api
                                                                            .urlDelReimburse))
                                                                  ..headers[
                                                                          'Content-Type'] =
                                                                      'multipart/form-data'
                                                                  ..fields[
                                                                          'nomor_reimburse'] =
                                                                      '${snapshot.data[index].nomorReimburse}';
                                                                await req
                                                                    .send();

                                                                idReimHapus.add(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .nomorReimburse);
                                                                snapshot.data
                                                                    .removeAt(
                                                                        index);

                                                                setState(() {
                                                                  EasyLoading
                                                                      .showSuccess(
                                                                          'Berhasil dihapus!');
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                        ],
                                      ),
                                      onTap: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          builder: (context) =>
                                              SingleChildScrollView(
                                            controller:
                                                ModalScrollController.of(
                                                    context),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .copyWith()
                                                      .size
                                                      .height *
                                                  0.90,
                                              padding: EdgeInsets.all(0),
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Row(children: [
                                                    SizedBox(width: 50),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                          "Detail Reimburse",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Icon(Icons.close,
                                                            size: 35,
                                                            color: Colors
                                                                .deepPurple)),
                                                  ]),
                                                  Divider(
                                                      color:
                                                          Colors.grey.shade400),
                                                  MediaQuery.removePadding(
                                                      context: context,
                                                      removeTop: true,
                                                      child: Expanded(
                                                        child: ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: snapshot
                                                                .data[index]
                                                                .detailReimburse
                                                                .length,
                                                            itemBuilder: (_,
                                                                    a) =>
                                                                Column(
                                                                    children: [
                                                                      ExpansionTile(
                                                                        title: Text(
                                                                            '${snapshot.data[index].detailReimburse[a].itemReimburse}'),
                                                                        subtitle:
                                                                            Text('Biaya: Rp ${uang.format(int.parse(snapshot.data[index].detailReimburse[a].biaya))}'),
                                                                        controlAffinity:
                                                                            ListTileControlAffinity.leading,
                                                                        children: <
                                                                            Widget>[
                                                                          ListTile(
                                                                              title: Image.network(
                                                                            '${util.Api.baseURL}/foto_nota/${snapshot.data[index].detailReimburse[a].image_bon}',
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            height:
                                                                                MediaQuery.of(context).size.width * 1,
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ])),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                              ],
                            ),
                          ));
                } else {
                  return Column(children: [
                    SizedBox(height: 50),
                    Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 5),
                          Text("Anda belum memiliki catatan reimbursement."),
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
            }),
      ),
      //bottomNavigationBar: menuUtama(1, context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          var res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddReimburse();
            }),
          );
          if (res != null && res) {
            loadData();
          }
        },
      ),
    );
  }
}
