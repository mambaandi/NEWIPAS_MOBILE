import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ipas_mobile/model/absensi_model.dart';
import 'package:ipas_mobile/model/cuti_model.dart';
import 'package:ipas_mobile/model/reimburse_model.dart';
import 'package:ipas_mobile/model/util.dart' as util;
import 'inventaris.dart';

class Api {
  static String baseURL = 'https://ipas.ptmds.co.id/api';
  static String urlLogin = '$baseURL/login_users.php';
  static String urlInventory = '$baseURL/list_inventaris.php';
  static String urlDelInventory = '$baseURL/delete_inventaris.php';
  static String urlInsertInventory = '$baseURL/create_inventaris.php';
  static String urlUpdateInventory = '$baseURL/update_inventaris.php';
  static String urlReimburse = '$baseURL/list_reimburse.php';
  static String urlInsertReimburse = '$baseURL/create_reimburse.php';
  static String urlInsertDetailReimburse =
      '$baseURL/create_detail_reimburse.php';
  static String urlDelReimburse = '$baseURL/delete_form_reimburse.php';
  static String urlDelItemReimburse = '$baseURL/delete_item_reimburse.php';
  static String urlUpdateReimburse = '$baseURL/update_total_reim.php';
  static String urlUpdateDetailReimburse =
      '$baseURL/update_detail_reimburse.php';
  static String urlAbsensi = '$baseURL/list_absensi.php';
  static String urlHistoriAbsensi = '$baseURL/list_histori_absensi.php';
  static String urlCheckIn = '$baseURL/create_absen_checkin.php';
  static String urlListCuti = '$baseURL/list_cuti.php';
  static String urlCreateCuti = '$baseURL/create_cuti.php';
  static String urlDeleteCuti = '$baseURL/delete_cuti.php';
  //static String urlCheckOut = '$baseURL/create_absen_checkin.php';
}

List<Inventaris> parseInventaris(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  var _inventaris = list.map((e) => Inventaris.fromJson(e)).toList();
  return _inventaris;
}

// ignore: missing_return
Future<List<Inventaris>> fetchInventaris(String userid) async {
  final http.Response response = await http.post(
    Uri.parse(util.Api.urlInventory),
    body: {'dibuat_oleh': userid},
  );
  /*await http.post(Uri.parse(
    util.Api.urlInventory
  ));*/

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Inventaris.fromJson(e)).toList();
    }
  }
}

List<ReimburseModel> parseReimburse(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  var _reimburse = list.map((e) => ReimburseModel.fromJson(e)).toList();
  return _reimburse;
}

Future<List<ReimburseModel>> fetchReimburse(String userid) async {
  final http.Response response = await http.post(
    Uri.parse(util.Api.urlReimburse),
    body: {'dibuat_oleh': userid},
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => ReimburseModel.fromJson(e)).toList();
    }
  }
  return Future.value([]);
}

Future<List<AbsenModel>> fetchDataAbsensi(String userid) async {
  http.Response response = await http
      .post(Uri.parse(util.Api.urlAbsensi), body: {'dibuat_oleh': userid});
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => AbsenModel.fromJson(e)).toList();
    }
  }
  return Future.value([]);
}

Future<List<AbsenModel>> fetchLastHistoriAbsensi(String userid) async {
  http.Response response = await http.post(
      Uri.parse(util.Api.urlHistoriAbsensi),
      body: {'dibuat_oleh': userid});
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => AbsenModel.fromJson(e)).toList();
    }
  }
  return Future.value([]);
}

Future<List<CutiModel>> fetchCuti(String userid) async {
  final http.Response response = await http.post(
    Uri.parse(util.Api.urlListCuti),
    body: {'dibuat_oleh': userid},
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => CutiModel.fromJson(e)).toList();
    }
  }
  return Future.value([]);
}
