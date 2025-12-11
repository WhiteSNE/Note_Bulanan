import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Kita butuh ini untuk format tanggal

class TambahTransaksiScreen extends StatefulWidget {
  // Update: Sekarang kita terima DateTime juga
  final Function(String, double, bool, DateTime) onTambah;

  const TambahTransaksiScreen({super.key, required this.onTambah});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  bool _isPengeluaran = true;
  
  // Variable untuk simpan tanggal yang dipilih (Default hari ini)
  DateTime _selectedDate = DateTime.now();

  // Fungsi memunculkan Kalender
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    final judulMasuk = _judulController.text;
    final jumlahMasuk = double.tryParse(_jumlahController.text) ?? 0;

    if (judulMasuk.isEmpty || jumlahMasuk <= 0) {
      return;
    }

    // Kirim data lengkap beserta Tanggalnya
    widget.onTambah(
      judulMasuk,
      jumlahMasuk,
      _isPengeluaran,
      _selectedDate, 
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Transaksi")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(labelText: 'Judul Transaksi'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // INPUT TANGGAL
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),

            const SizedBox(height: 20),

            // SWITCH PENGELUARAN/PEMASUKAN
            Row(
              children: [
                const Text("Jenis: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_isPengeluaran ? "Pengeluaran" : "Pemasukan", 
                  style: TextStyle(color: _isPengeluaran ? Colors.red : Colors.green)
                ),
                const Spacer(),
                Switch(
                  value: _isPengeluaran,
                  activeThumbColor: Colors.red,
                  inactiveThumbColor: Colors.green,
                  inactiveTrackColor: Colors.green[200],
                  onChanged: (val) {
                    setState(() {
                      _isPengeluaran = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}