// import 'dart:convert';
//
// ReimburseModel reimburseModelFromJson(String str) => ReimburseModel.fromJson(json.decode(str));
//
// String reimburseModelToJson(ReimburseModel data) => json.encode(data.toJson());
//
// class ReimburseModel {
//   ReimburseModel({
//     this.idReimburse,
//     this.nomorReimburse,
//     this.totalReimburse,
//     this.dibuatTanggal,
//     this.idDetailReimburse,
//     this.nomorReimb,
//     this.itemReimburse,
//     this.biaya,
//   });
//
//   String idReimburse;
//   String nomorReimburse;
//   String totalReimburse;
//   DateTime dibuatTanggal;
//   String idDetailReimburse;
//   String nomorReimb;
//   String itemReimburse;
//   String biaya;
//
//   factory ReimburseModel.fromJson(Map<String, dynamic> json) => ReimburseModel(
//     idReimburse: json["id_reimburse"] == null ? null : json["id_reimburse"],
//     nomorReimburse: json["nomor_reimburse"] == null ? null : json["nomor_reimburse"],
//     totalReimburse: json["total_reimburse"] == null ? null : json["total_reimburse"],
//     dibuatTanggal: json["dibuat_tanggal"] == null ? null : DateTime.parse(json["dibuat_tanggal"]),
//     idDetailReimburse: json["id_detail_reimburse"] == null ? null : json["id_detail_reimburse"],
//     nomorReimb: json["nomor_reimb"] == null ? null : json["nomor_reimb"],
//     itemReimburse: json["item_reimburse"] == null ? null : json["item_reimburse"],
//     biaya: json["biaya"] == null ? null : json["biaya"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id_reimburse": idReimburse == null ? null : idReimburse,
//     "nomor_reimburse": nomorReimburse == null ? null : nomorReimburse,
//     "total_reimburse": totalReimburse == null ? null : totalReimburse,
//     "dibuat_tanggal": dibuatTanggal == null ? null : dibuatTanggal.toIso8601String(),
//     "id_detail_reimburse": idDetailReimburse == null ? null : idDetailReimburse,
//     "nomor_reimb": nomorReimb == null ? null : nomorReimb,
//     "item_reimburse": itemReimburse == null ? null : itemReimburse,
//     "biaya": biaya == null ? null : biaya,
//   };
// }
// To parse this JSON data, do
//
//     final reimburseModel = reimburseModelFromJson(jsonString);

import 'dart:convert';

List<ReimburseModel> reimburseModelFromJson(String str) =>
    List<ReimburseModel>.from(
        json.decode(str).map((x) => ReimburseModel.fromJson(x)));

String reimburseModelToJson(List<ReimburseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReimburseModel {
  ReimburseModel(
      {this.idReimburse,
      this.nomorReimburse,
      this.totalReimburse,
      this.dibuatTanggal,
      this.detailReimburse,
      this.statusReimburse,
      this.keteranganTolak});

  String idReimburse;
  String nomorReimburse;
  String totalReimburse;
  String statusReimburse;
  String keteranganTolak;
  DateTime dibuatTanggal;
  List<DetailReimburse> detailReimburse;

  factory ReimburseModel.fromJson(Map<String, dynamic> json) => ReimburseModel(
        idReimburse: json["id_reimburse"] == null ? null : json["id_reimburse"],
        nomorReimburse:
            json["nomor_reimburse"] == null ? null : json["nomor_reimburse"],
        totalReimburse:
            json["total_reimburse"] == null ? null : json["total_reimburse"],
        statusReimburse:
            json["status_reimburse"] == null ? null : json["status_reimburse"],
        keteranganTolak:
            json["keterangan_tolak"] == null ? null : json["keterangan_tolak"],
        dibuatTanggal: json["dibuat_tanggal"] == null
            ? null
            : DateTime.parse(json["dibuat_tanggal"]),
        detailReimburse: json["detail_reimburse"] == null
            ? null
            : List<DetailReimburse>.from(json["detail_reimburse"]
                .map((x) => DetailReimburse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id_reimburse": idReimburse == null ? null : idReimburse,
        "nomor_reimburse": nomorReimburse == null ? null : nomorReimburse,
        "total_reimburse": totalReimburse == null ? null : totalReimburse,
        "dibuat_tanggal":
            dibuatTanggal == null ? null : dibuatTanggal.toIso8601String(),
        "detail_reimburse": detailReimburse == null
            ? null
            : List<dynamic>.from(detailReimburse.map((x) => x.toJson())),
      };
}

class DetailReimburse {
  DetailReimburse(
      {this.idDetailReimburse,
      this.nomorReimb,
      this.itemReimburse,
      this.biaya,
      // ignore: non_constant_identifier_names
      this.image_bon});

  String idDetailReimburse;
  String nomorReimb;
  String itemReimburse;
  String biaya;
  // ignore: non_constant_identifier_names
  String image_bon;

  factory DetailReimburse.fromJson(Map<String, dynamic> json) =>
      DetailReimburse(
          idDetailReimburse: json["id_detail_reimburse"] == null
              ? null
              : json["id_detail_reimburse"],
          nomorReimb: json["nomor_reimb"] == null ? null : json["nomor_reimb"],
          itemReimburse:
              json["item_reimburse"] == null ? null : json["item_reimburse"],
          biaya: json["biaya"] == null ? null : json["biaya"],
          image_bon: json["image_bon"] == null ? null : json["image_bon"]);

  Map<String, dynamic> toJson() => {
        "id_detail_reimburse":
            idDetailReimburse == null ? null : idDetailReimburse,
        "nomor_reimb": nomorReimb == null ? null : nomorReimb,
        "item_reimburse": itemReimburse == null ? null : itemReimburse,
        "biaya": biaya == null ? null : biaya,
        "image_bon": image_bon == null ? null : image_bon
      };
}
