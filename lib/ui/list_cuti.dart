import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ipas_mobile/model/cuti_model.dart';
import 'package:ipas_mobile/model/util.dart';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/util.dart' as util;
import 'package:intl/intl.dart';
import 'package:ipas_mobile/ui/add_cuti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class ListCuti extends StatefulWidget {
  @override
  _ListCutiState createState() => _ListCutiState();
}

class _ListCutiState extends State<ListCuti> {
  Future<List<CutiModel>> listCuti = Future.value([]);
  List<String> idDelCuti = [];
  final uang = NumberFormat('#,###', "id");
  String userid = "";
  String name = "";
  String branchID = "";
  int ambilStatus;

  List<String> _pilStatus = [
    'Direview',
    'Disetujui',
    'Ditolak',
  ];

  @override
  void initState() {
    getPref();
    super.initState();
  }

  loadData() {
    fetchCuti(userid).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          listCuti = Future.value(value);
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
        leading: IconButton(
          onPressed: () {},
          icon: IconButton(onPressed: () {}, icon: Icon(Icons.event_available)),
        ),
        title: Text(
          'History Cuti',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: FutureBuilder(
            future: listCuti,
            builder: (_, AsyncSnapshot<List<CutiModel>> snapshot) {
              //cek data ada atau tidak
              if (snapshot.hasData) {
                // cek jumlah dalam list lebih dari 0?
                if (snapshot.data.length > 0) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
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
                                      leading: Hero(
                                        tag: snapshot.data[index].idCuti,
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
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                                'Tanggal Cuti ${(DateFormat('dd MMM yyyy').format(snapshot.data[index].tglMulai))} s/d ${(DateFormat('dd MMM yyyy').format(snapshot.data[index].tglAkhir))}'),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: badges.Badge(
                                                    position:
                                                        badges.BadgePosition
                                                            .topEnd(
                                                                top: -10,
                                                                end: -12),
                                                    showBadge: true,
                                                    ignorePointer: false,
                                                    onTap: () {},
                                                    badgeContent: snapshot
                                                                .data[index]
                                                                .statusCuti ==
                                                            ""
                                                        ? Text(
                                                            "${_pilStatus[0]}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13))
                                                        : Text(
                                                            "${_pilStatus[0]}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13)),
                                                    badgeStyle:
                                                        badges.BadgeStyle(
                                                      shape: badges
                                                          .BadgeShape.square,
                                                      badgeColor: (snapshot
                                                                  .data[index]
                                                                  .statusCuti ==
                                                              "")
                                                          ? Colors.deepPurple
                                                          : (snapshot
                                                                      .data[
                                                                          index]
                                                                      .statusCuti ==
                                                                  "1")
                                                              ? Colors.green
                                                                  .shade400
                                                              : Colors.red,
                                                      padding:
                                                          EdgeInsets.all(7),
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
                                                    position:
                                                        badges.BadgePosition
                                                            .topEnd(
                                                                top: -10,
                                                                end: -12),
                                                    showBadge: true,
                                                    ignorePointer: false,
                                                    onTap: () {},
                                                    badgeContent: Text(
                                                      ' ${snapshot.data[index].hariCuti} hari',
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                    badgeStyle:
                                                        badges.BadgeStyle(
                                                      shape: badges
                                                          .BadgeShape.square,
                                                      badgeColor: Colors.amber,
                                                      padding:
                                                          EdgeInsets.all(7),
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
                                                  child: Container(
                                                    height: 20,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        snapshot.data[index]
                                                                    .statusCuti ==
                                                                ""
                                                            ? IconButton(
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                ),
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                        ),
                                                                        title: Column(
                                                                            children: [
                                                                              const Text('Alert'),
                                                                              Divider(color: Colors.grey.shade400)
                                                                            ]),
                                                                        content:
                                                                            Text('Hapus pengajuan cuti tanggal ${(DateFormat('dd MMM yyyy').format(snapshot.data[index].tglMulai))} s/d ${(DateFormat('dd MMM yyyy').format(snapshot.data[index].tglAkhir))} ?'),
                                                                        actions: <
                                                                            Widget>[
                                                                          ElevatedButton(
                                                                            child:
                                                                                const Text('Tidak'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                          TextButton(
                                                                            child:
                                                                                const Text('Ya, Hapus!'),
                                                                            onPressed:
                                                                                () async {
                                                                              var req = http.MultipartRequest('POST', Uri.parse(util.Api.urlDeleteCuti))
                                                                                ..headers['Content-Type'] = 'multipart/form-data'
                                                                                ..fields['idCuti'] = '${snapshot.data[index].idCuti}';
                                                                              await req.send();

                                                                              idDelCuti.add(snapshot.data[index].idCuti);
                                                                              snapshot.data.removeAt(index);

                                                                              setState(() {
                                                                                EasyLoading.showSuccess('Berhasil dihapus!');
                                                                              });
                                                                              Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              )
                                                            : Text(""),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                          ]),
                                      isThreeLine: true,
                                      dense: false,
                                      onTap: () {
                                        //EasyLoading.showInfo("belum ada apa2");
                                      },
                                    )),
                                SizedBox(height: 5)
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
                          Text("Anda belum memiliki catatan cuti."),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          var res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddCuti();
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
