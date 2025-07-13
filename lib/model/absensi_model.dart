// To parse this JSON data, do
//
//     final absenModel = absenModelFromJson(jsonString);

import 'dart:convert';

List<AbsenModel> absenModelFromJson(String str) => List<AbsenModel>.from(json.decode(str).map((x) => AbsenModel.fromJson(x)));

String absenModelToJson(List<AbsenModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AbsenModel {
  AbsenModel({
    this.idAbsen,
    this.idUser,
    this.tglCheckin,
    this.tglCheckout,
    this.imageCheckin,
    this.imageCheckout,
    this.longlatCheckin,
    this.longlatCheckout,
    this.alamatCheckin,
    this.alamatCheckout,
  });

  String idAbsen;
  String idUser;
  DateTime tglCheckin;
  DateTime tglCheckout;
  String imageCheckin;
  String imageCheckout;
  String longlatCheckin;
  String longlatCheckout;
  String alamatCheckin;
  String alamatCheckout;

  factory AbsenModel.fromJson(Map<String, dynamic> json) => AbsenModel(
    idAbsen: json["id_absen"] == null ? null : json["id_absen"],
    idUser: json["id_user"] == null ? null : json["id_user"],
    tglCheckin: json["tgl_checkin"] == null ? null : DateTime.parse(json["tgl_checkin"]),
    tglCheckout: json["tgl_checkout"] == null ? null : DateTime.parse(json["tgl_checkout"]),
    imageCheckin: json["image_checkin"] == null ? null : json["image_checkin"],
    imageCheckout: json["image_checkout"] == null ? null : json["image_checkout"],
    longlatCheckin: json["longlat_checkin"] == null ? null : json["longlat_checkin"],
    longlatCheckout: json["longlat_checkout"] == null ? null : json["longlat_checkout"],
    alamatCheckin: json["alamat_checkin"] == null ? null : json["alamat_checkin"],
    alamatCheckout: json["alamat_checkout"] == null ? null : json["alamat_checkout"],
  );

  Map<String, dynamic> toJson() => {
    "id_absen": idAbsen == null ? null : idAbsen,
    "id_user": idUser == null ? null : idUser,
    "tgl_checkin": tglCheckin == null ? null : tglCheckin.toIso8601String(),
    "tgl_checkout": tglCheckout == null ? null : tglCheckout.toIso8601String(),
    "image_checkin": imageCheckin == null ? null : imageCheckin,
    "image_checkout": imageCheckout == null ? null : imageCheckout,
    "longlat_checkin": longlatCheckin == null ? null : longlatCheckin,
    "longlat_checkout": longlatCheckout == null ? null : longlatCheckout,
    "alamat_checkin": alamatCheckin == null ? null : alamatCheckin,
    "alamat_checkout": alamatCheckout == null ? null : alamatCheckout,
  };
}
