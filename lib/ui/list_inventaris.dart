import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:ipas_mobile/model/inventaris.dart';
import 'package:ipas_mobile/model/util.dart';
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:ipas_mobile/ui/home_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListInven extends StatefulWidget {
  @override
  _ListInvenState createState() => _ListInvenState();
}

class _ListInvenState extends State<ListInven> {
  Future<List<Inventaris>> listInventaris = Future.value([]);
  List<String> idInvenHapus = [];
  final ScrollController _controllerOne = ScrollController();
  List<String> _pilStatus = [
    'Dikirim',
    'Diterima',
    'Pengembalian',
    'Rusak',
  ];

  String userid = "";
  String name = "";
  String branchID = "";
  int ambilStatus;

  @override
  void initState() {
    getPref();
    super.initState();
  }

  loadData() {
    fetchInventaris(userid).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          listInventaris = Future.value(value);
        });
      }
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("name");
      userid = preferences.getString("id");
      branchID = preferences.getString("branch_id");
      ambilStatus = preferences.getInt('status');
      print("userid=$userid");
      print("name=$name");
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          'Daftar Inventaris',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: FutureBuilder(
            future: listInventaris,
            builder: (_, AsyncSnapshot<List<Inventaris>> snapshot) {
              //cek data ada atau tidak
              if (snapshot.hasData) {
                // cek jumlah dalam list lebih dari 0?
                if (snapshot.data.length > 0) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      controller: _controllerOne,
                      itemBuilder: (_, index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
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
                                        tag: snapshot.data[index].idBarang,
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
                                          '${snapshot.data[index].namaBarang}'),
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Note: ${snapshot.data[index].noteBarang}'),
                                            SizedBox(height: 10),
                                            Row(children: [
                                              Expanded(
                                                flex: 2,
                                                child: badges.Badge(
                                                  position: badges.BadgePosition
                                                      .topEnd(
                                                          top: -10, end: -12),
                                                  showBadge: true,
                                                  ignorePointer: false,
                                                  onTap: () {},
                                                  badgeContent: Text(
                                                      '${_pilStatus[int.parse(snapshot.data[index].infoBarang)]}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13)),
                                                  badgeStyle: badges.BadgeStyle(
                                                    shape: badges
                                                        .BadgeShape.square,
                                                    badgeColor: int.parse(snapshot
                                                                .data[index]
                                                                .infoBarang) <
                                                            2
                                                        ? Colors.green.shade400
                                                        : Colors.red,
                                                    padding: EdgeInsets.all(7),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      bottomLeft:
                                                          Radius.circular(5),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: badges.Badge(
                                                  position: badges.BadgePosition
                                                      .topEnd(
                                                          top: -10, end: -12),
                                                  showBadge: true,
                                                  ignorePointer: false,
                                                  onTap: () {},
                                                  badgeContent: Text(
                                                    '  ${snapshot.data[index].jumlahBarang} buah',
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  badgeStyle: badges.BadgeStyle(
                                                    shape: badges
                                                        .BadgeShape.square,
                                                    badgeColor: Colors.amber,
                                                    padding: EdgeInsets.all(7),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(5),
                                                      bottomRight:
                                                          Radius.circular(5),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(''),
                                              )
                                            ]),
                                          ]),
                                      isThreeLine: true,
                                      dense: false,
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /*IconButton(
                                              icon: Icon(Icons.edit_outlined),
                                              onPressed: () async {
                                                var res =
                                                    await Navigator.of(context)
                                                        .push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return AddInventaris(
                                                        editInventaris: snapshot
                                                            .data[index]);
                                                  }),
                                                );
                                                if (res != null && res) {
                                                  loadData();
                                                }
                                              },
                                            ),*/
                                            /*IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  title: Column(children: [
                                                    const Text('Alert'),
                                                    Divider(
                                                        color: Colors
                                                            .grey.shade400)
                                                  ]),
                                                  content: Text(
                                                      'Apakah data [${snapshot.data[index].namaBarang}] akan dihapus ?'),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      child:
                                                          const Text('Tidak'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                          'Ya, Hapus!'),
                                                      onPressed: () async {
                                                        await http.post(
                                                          Uri.parse(util.Api
                                                              .urlDelInventory),
                                                          body: {
                                                            'id_barang':
                                                                snapshot
                                                                    .data[index]
                                                                    .idBarang,
                                                            'nama_file':
                                                                snapshot
                                                                    .data[index]
                                                                    .image
                                                          },
                                                        );

                                                        idInvenHapus.add(
                                                            snapshot.data[index]
                                                                .idBarang);
                                                        snapshot.data
                                                            .removeAt(index);
                                                        setState(() {
                                                          EasyLoading.showSuccess(
                                                              'Berhasil dihapus!');
                                                        });

                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),*/
                                          ]),
                                      onTap: () {
                                        showMaterialModalBottomSheet(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          context: context,
                                          builder: (context) =>
                                              SingleChildScrollView(
                                            controller:
                                                ModalScrollController.of(
                                                    context),
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              //height: 90%,
                                              child: Column(
                                                children: [
                                                  Row(children: [
                                                    SizedBox(width: 50),
                                                    Container(
                                                      width: 250,
                                                      child: Text("Foto Barang",
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
                                                            size: 40,
                                                            color: Colors.red)),
                                                  ]),
                                                  Divider(
                                                      color:
                                                          Colors.grey.shade400),
                                                  Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.network(
                                                        '${util.Api.baseURL}/foto_barang/${snapshot.data[index].image}',
                                                        height: 350.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                SizedBox(height: 7)
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
                          Text("Anda belum memiliki catatan iventaris."),
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
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          var res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddInventaris(
                editInventaris: null,
              );
            }),
          );

          if (res != null && res) {
            loadData();
          }
        },
      ),*/
    );
  }
}
