import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:ipas_mobile/model/reimburse_model.dart';

class ListReimburse extends StatefulWidget {
  final Map<String, dynamic> dataRemburse;

  ListReimburse({
    @required this.dataRemburse,
  });

  @override
  _ListReimburseState createState() => _ListReimburseState();
}

class _ListReimburseState extends State<ListReimburse> {
  List<DetailReimburse> listRemburse = [];
  List<String> idItemHapus = [];

  @override
  void initState() {
    if (widget.dataRemburse.isNotEmpty) {
      List data = widget.dataRemburse['detail_reimburse'];
      data.map((e) => listRemburse.add(DetailReimburse.fromJson(e))).toList();
    }
    super.initState();
    print(widget.dataRemburse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          'Daftar Detail Reimburse',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFC2DD5F),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: ListView.builder(
            // itemCount: widget.noReimb['detail_reimburse'].length,
            itemCount: listRemburse.length,
            itemBuilder: (_, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Hero(
                          tag: listRemburse[index].idDetailReimburse,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF818550),
                            radius: 40.0,
                            child: new Text(
                              '${listRemburse[index].idDetailReimburse}',
                              style: TextStyle(color: Colors.white),
                            ),
                            //backgroundImage: NetworkImage(user.image),
                          ),
                        ),
                        title: Text(
                            'Nama Item : ${listRemburse[index].itemReimburse}'),
                        subtitle: Text(
                            'Harga Per Item : Rp.${listRemburse[index].biaya}'),
                        onTap: () {},
                      ),
                      Divider(
                        thickness: 2.0,
                      ),
                    ],
                  ),
                )),
      ),
    );
  }
}
