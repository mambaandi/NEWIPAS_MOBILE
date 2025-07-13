import 'package:flutter/material.dart';
import 'package:ipas_mobile/model/inventaris.dart';
import 'package:http/http.dart' as http;

class InventarisTile extends StatelessWidget {
  final Inventaris lstInventaris;
  final int nomor;

  InventarisTile({this.lstInventaris, this.nomor});

  void deleteInventaris(context) async {
    await http.post(
      Uri.parse("https://inovbaba.com/inventory/delete.php"),
      body: {
        'id_barang': lstInventaris.idBarang.toString(),
      },
    );
    Navigator.pop(context);
  }

  void confirmDelete(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Yakin Dihapus ?'),
          actions: <Widget>[
            ElevatedButton(
              child: Icon(Icons.cancel),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Icon(Icons.check_circle),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                deleteInventaris(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          ListTile(
            leading: Hero(
              tag: lstInventaris.idBarang,
              child: CircleAvatar(
                backgroundColor: Color(0xFF818550),
                radius: 40.0,
                child: new Text(
                  nomor.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                //backgroundImage: NetworkImage(user.image),
              ),
            ),
            title: Text('${lstInventaris.namaBarang}'),
            subtitle: Text(lstInventaris.infoBarang),
            trailing: IconButton(
                onPressed: () {
                  confirmDelete(context);
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) {
              //     return DetailInventaris(lstInventaris);
              //   }),
              // );
            },
          ),
          Divider(
            thickness: 2.0,
          ),
        ],
      ),
    );
  }
}
