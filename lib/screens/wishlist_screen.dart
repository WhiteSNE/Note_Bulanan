import 'package:flutter/material.dart';
import '../models/wishlist.dart';

class WishlistScreen extends StatelessWidget {
  final List<Wishlist> daftarWishlist;
  final Function(int) onToggleStatus;
  final Function(int) onDelete;

  // TAMBAHAN: Kita butuh data saldo untuk ditampilkan di pop-up
  final double currentBalance;

  const WishlistScreen({
    super.key,
    required this.daftarWishlist,
    required this.onToggleStatus,
    required this.onDelete,
    required this.currentBalance, // <--- Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    if (daftarWishlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text(
              "Belum ada keinginan.",
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              "Ayo pasang target!",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: daftarWishlist.length,
      itemBuilder: (context, index) {
        final item = daftarWishlist[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            // LOGIKA CHECKBOX BARU
            leading: Checkbox(
              value: item.isTercapai,
              activeColor: Colors.teal,
              onChanged: (bool? newValue) {
                // Jika user mau mencentang (membeli)
                if (newValue == true) {
                  // TAMPILKAN POP-UP KONFIRMASI
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Yakin mau beli?"),
                      content: Text(
                        "Tabungan kamu masih Rp ${currentBalance.toStringAsFixed(0)}.\n\n"
                        "Setelah beli ini, saldo akan berkurang sebesar Rp ${item.harga.toStringAsFixed(0)}.",
                      ),
                      actions: [
                        // Tombol Batal
                        TextButton(
                          onPressed: () => Navigator.pop(ctx), // Tutup dialog
                          child: const Text("Pikir Dulu"),
                        ),
                        // Tombol Beli
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx); // Tutup dialog
                            onToggleStatus(index); // EKSEKUSI BELI
                          },
                          child: const Text(
                            "Gas Beli!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Jika user mau uncheck (batal beli), langsung eksekusi aja gak perlu tanya
                  onToggleStatus(index);
                }
              },
            ),

            title: Text(
              item.namaBarang,
              style: TextStyle(
                decoration: item.isTercapai ? TextDecoration.lineThrough : null,
                color: item.isTercapai ? Colors.grey : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text("Rp ${item.harga.toStringAsFixed(0)}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(index),
            ),
          ),
        );
      },
    );
  }
}
