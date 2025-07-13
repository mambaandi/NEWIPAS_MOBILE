class Inventaris {
  String idBarang = "";
  String namaBarang = "";
  String infoBarang = "";
  String jumlahBarang = "";
  String noteBarang = "";
  String image = "";
  String branchID = "";
  String userID = "";

  Inventaris(this.idBarang, this.namaBarang, this.infoBarang, this.jumlahBarang,
      this.noteBarang, this.image, this.branchID, this.userID);

  Inventaris.fromJson(Map<String, dynamic> json) {
    idBarang = json['id_barang'];
    namaBarang = json['nama_barang'];
    infoBarang = json['informasi_barang'];
    jumlahBarang = json['jumlah_barang'];
    noteBarang = json['note'];
    image = json['image_barang'];
    branchID = json['branch_id'];
    userID = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_barang'] = this.idBarang;
    data['nama_barang'] = this.namaBarang;
    data['info_barang'] = this.infoBarang;
    data['jumlah_barang'] = this.jumlahBarang;
    data['note'] = this.noteBarang;
    data['image_barang'] = this.image;
    data['branchID'] = this.branchID;
    data['userID'] = this.userID;
    return data;
  }
}
