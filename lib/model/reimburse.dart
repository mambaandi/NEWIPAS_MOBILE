// To parse this JSON data, do
//
//     final reimburse = reimburseFromJson(jsonString);

import 'dart:convert';

Reimburse reimburseFromJson(String str) => Reimburse.fromJson(json.decode(str));

String reimburseToJson(Reimburse data) => json.encode(data.toJson());

class Reimburse {
  Reimburse({
    this.idReimburse,
    this.noReimburse,
    this.totalReimburse,
    this.listItem,
  });

  String noReimburse;
  String idReimburse;
  double totalReimburse;
  List<ListItem> listItem;

  factory Reimburse.fromJson(Map<String, dynamic> json) => Reimburse(
        idReimburse: json["id_reimburse"] == null ? null : json["id_reimburse"],
        noReimburse:
            json["nomor_reimburse"] == null ? null : json["nomor_reimburse"],
        totalReimburse:
            json["total_reimburse"] == null ? null : json["total_reimburse"],
        listItem: json["list_item"] == null
            ? null
            : List<ListItem>.from(
                json["list_item"].map((x) => ListItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id_reimburse": idReimburse == null ? null : idReimburse,
        "nomor_reimburse": noReimburse == null ? null : noReimburse,
        "total_reimburse": totalReimburse == null ? null : totalReimburse,
        "list_item": listItem == null
            ? null
            : List<dynamic>.from(listItem.map((x) => x.toJson())),
      };
}

class ListItem {
  ListItem({
    this.namaReimburse,
    this.biaya,
    this.nomorReimburse,
    this.idDetailReimburse,
  });

  String namaReimburse;
  double biaya;
  String nomorReimburse;
  int idDetailReimburse;

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        nomorReimburse:
            json["nomor_reimb"] == null ? null : json["nomor_reimb"],
        namaReimburse:
            json["item_reimburse"] == null ? null : json["item_reimburse"],
        biaya: json["biaya"] == null ? null : json["biaya"],
        idDetailReimburse: json["id_detail_reimburse"] == null
            ? null
            : json["id_detail_reimburse"],
      );

  Map<String, dynamic> toJson() => {
        "item_reimburse": namaReimburse == null ? null : namaReimburse,
        "biaya": biaya == null ? null : biaya,
        "nomor_reimb": nomorReimburse == null ? null : nomorReimburse,
        "id_detail_reimburse":
            idDetailReimburse == null ? null : idDetailReimburse,
      };
}
