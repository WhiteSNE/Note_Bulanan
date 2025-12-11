import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart'; 

class RiwayatTransaksi extends StatelessWidget {
  final List<Transaksi> daftarTransaksi;
  
  // Fungsi yang kita terima dari main.dart
  final Function(Transaksi) onHapus; 

  const RiwayatTransaksi({
    super.key, 
    required this.daftarTransaksi,
    required this.onHapus, // Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    if (daftarTransaksi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 70, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("Belum ada transaksi bulan ini.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: daftarTransaksi.length,
      itemBuilder: (context, index) {
        final tx = daftarTransaksi[index];
        
        // DISMISSIBLE: Widget agar bisa digeser
        return Dismissible(
          // Key: Identitas unik tiap item (Wajib ada)
          key: ValueKey(tx), 
          
          // Arah geser: Hanya bisa geser dari kanan ke kiri
          direction: DismissDirection.endToStart, 
          
          // Tampilan Background saat digeser (Warna Merah + Tong Sampah)
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),

          // KONFIRMASI SEBELUM HAPUS
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Hapus Data?"),
                content: Text("Kamu yakin ingin menghapus '${tx.judul}'?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false), // Jangan Hapus
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.of(ctx).pop(true), // Ya, Hapus
                    child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },

          // AKSI SETELAH DIKONFIRMASI
          onDismissed: (direction) {
            onHapus(tx); // Panggil fungsi hapus di main.dart
          },

          // KARTU TRANSAKSI ASLI (Anak dari Dismissible)
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tx.isPengeluaran ? Colors.red[100] : Colors.green[100],
                child: Icon(
                  tx.isPengeluaran ? Icons.arrow_downward : Icons.arrow_upward,
                  color: tx.isPengeluaran ? Colors.red : Colors.green,
                ),
              ),
              title: Text(tx.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('dd MMM yyyy').format(tx.tanggal)),
              trailing: Text(
                "Rp ${tx.jumlah < 1000000 ? (tx.jumlah/1000).toStringAsFixed(0) + 'k' : (tx.jumlah/1000000).toStringAsFixed(1) + 'jt'}",
                style: TextStyle(
                  color: tx.isPengeluaran ? Colors.red : Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}