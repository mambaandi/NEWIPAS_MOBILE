import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipas_mobile/model/absensi_model.dart';
import 'package:ipas_mobile/model/util.dart';
import 'package:ipas_mobile/ui/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilAbsensi extends StatefulWidget {
  @override
  _ProfilAbsensiState createState() => _ProfilAbsensiState();
}

class _ProfilAbsensiState extends State<ProfilAbsensi>
    with SingleTickerProviderStateMixin {
  Future<List<AbsenModel>> listAbsen = Future.value([]);
  String tanggalCheckin;
  String tanggalCheckout;
  String jamCheckin;
  String jamCheckout;
  TabController controller;
  String userid = "";
  String name = "";
  String branchID = "";
  int ambilStatus;

  @override
  void initState() {
    getPref();
    controller = new TabController(vsync: this, length: 2);
    super.initState();
  }

  loadData() {
    fetchDataAbsensi(userid).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          listAbsen = Future.value(value);
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
          title: Text('Histori Absensi'),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.grey.shade100,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _historiAbsensi(),
            ),
          ),
        ));
  }

  _historiAbsensi() => FutureBuilder(
        future: listAbsen,
        builder: (_, AsyncSnapshot<List<AbsenModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        DateTime konversiTgl = DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse("${snapshot.data[index].tglCheckin}");
                        tanggalCheckin = DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(konversiTgl);

                        DateTime konversiTglOut =
                            DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                (snapshot.data[index].tglCheckout == null)
                                    ? "0000-00-00 00:00:00"
                                    : "${snapshot.data[index].tglCheckout}");
                        var tanggalCheckOut =
                            (snapshot.data[index].tglCheckout == null)
                                ? "-"
                                : DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(konversiTglOut);

                        return Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 5),
                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  width: 60,
                                  height: 50,
                                  child: new Image.asset(
                                    'assets/images/in.png',
                                    alignment: Alignment.centerLeft,
                                    width: 5,
                                    height: 2,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text('Check In : $tanggalCheckin'),
                                        Container(
                                          width: 250,
                                          child: Text(
                                            'Lokasi: ${snapshot.data[index].alamatCheckin}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        if (tanggalCheckOut != '')
                                          SizedBox(height: 10),
                                        Text('Check Out : $tanggalCheckOut'),
                                        Container(
                                          width: 250,
                                          child: (snapshot.data[index]
                                                      .alamatCheckout ==
                                                  null)
                                              ? Text('Lokasi:-',
                                                  style: TextStyle(
                                                      color: Colors.grey))
                                              : Text(
                                                  'Lokasi: ${snapshot.data[index].alamatCheckout}',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }));
            } else {
              return Column(children: [
                SizedBox(height: 50),
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 5),
                      Text("Anda belum memiliki catatan kehadiran."),
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
        },
      );
}
