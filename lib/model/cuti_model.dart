import 'dart:convert';

List<CutiModel> cutiModelFromJson(String str) =>
    List<CutiModel>.from(json.decode(str).map((x) => CutiModel.fromJson(x)));

String cutiModelToJson(List<CutiModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CutiModel {
  CutiModel(
      {this.idCuti,
      this.idPegawai,
      this.namaLengkap,
      this.tglMulai,
      this.tglAkhir,
      this.hariCuti,
      this.alasanCuti,
      this.cutiKhusus,
      this.sisaCuti,
      this.statusCuti});

  String idCuti;
  String idPegawai;
  String namaLengkap;
  DateTime tglMulai;
  DateTime tglAkhir;
  String hariCuti;
  String alasanCuti;
  String cutiKhusus;
  int sisaCuti;
  String statusCuti;
  //List<DetailReimburse> detailReimburse;

  factory CutiModel.fromJson(Map<String, dynamic> json) => CutiModel(
        idCuti: json["id_cuti"] == null ? null : json["id_cuti"],
        idPegawai: json["id_pegawai"] == null ? null : json["id_pegawai"],
        namaLengkap: json["nama_lengkap"] == null ? null : json["nama_lengkap"],
        tglMulai: json["tanggal_mulai"] == null
            ? null
            : DateTime.parse(json["tanggal_mulai"]),
        tglAkhir: json["tanggal_akhir"] == null
            ? null
            : DateTime.parse(json["tanggal_akhir"]),
        hariCuti: json["hari_cuti"] == null ? null : json["hari_cuti"],
        alasanCuti: json["alasan_cuti"] == null ? null : json["alasan_cuti"],
        cutiKhusus: json["cuti_khusus"] == null ? null : json["cuti_khusus"],
        sisaCuti: json["sisa_cuti"] == null ? null : json["sisa_cuti"],
        statusCuti: json["status_cuti"] == null ? null : json["status_cuti"],
      );

  Map<String, dynamic> toJson() => {
        "id_cuti": idCuti == null ? null : idCuti,
        "id_pegawai": idPegawai == null ? null : idPegawai,
        "nama_lengkap": namaLengkap == null ? null : namaLengkap,
        "tanggal_mulai": tglMulai == null ? null : tglMulai.toIso8601String(),
        "tanggal_akhir": tglAkhir == null ? null : tglAkhir.toIso8601String(),
        "hari_cuti": hariCuti == null ? null : hariCuti,
        "alasan_cuti": alasanCuti == null ? null : alasanCuti,
        "cuti_khusus": cutiKhusus == null ? null : cutiKhusus,
        "sisa_cuti": sisaCuti == null ? null : sisaCuti,
        "status_cuti": statusCuti == null ? null : statusCuti,
      };
}
