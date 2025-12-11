class Transaksi {
  final String judul;
  final double jumlah;
  final bool isPengeluaran;
  final DateTime tanggal;

  Transaksi({
    required this.judul,
    required this.jumlah,
    required this.isPengeluaran,
    required this.tanggal,
  });

  // 1. Mengubah Object jadi JSON (Untuk Disimpan)
  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'jumlah': jumlah,
      'isPengeluaran': isPengeluaran,
      'tanggal': tanggal.toIso8601String(), // Tanggal disimpan sebagai teks
    };
  }

  // 2. Mengubah JSON jadi Object (Untuk Dibaca)
  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      judul: json['judul'],
      jumlah: json['jumlah'],
      isPengeluaran: json['isPengeluaran'],
      tanggal: DateTime.parse(json['tanggal']), // Teks diubah balik ke Tanggal
    );
  }
}