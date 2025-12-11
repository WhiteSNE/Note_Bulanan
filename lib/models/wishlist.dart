class Wishlist {
  final String namaBarang;
  final double harga;
  bool isTercapai;

  Wishlist({
    required this.namaBarang,
    required this.harga,
    this.isTercapai = false,
  });

  // 1. Ke JSON
  Map<String, dynamic> toJson() {
    return {
      'namaBarang': namaBarang,
      'harga': harga,
      'isTercapai': isTercapai,
    };
  }

  // 2. Dari JSON
  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      namaBarang: json['namaBarang'],
      harga: json['harga'],
      isTercapai: json['isTercapai'],
    );
  }
}