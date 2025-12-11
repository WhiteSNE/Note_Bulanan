import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert'; // PENTING: Untuk mengolah JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'tema_aplikasi.dart';

import 'models/transaksi.dart';
import 'models/wishlist.dart';
import 'screens/dashboard.dart';
import 'screens/riwayat.dart';
import 'screens/tambah_transaksi.dart';
import 'screens/pengaturan.dart';
import 'screens/wishlist_screen.dart';
import 'screens/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final String savedName = prefs.getString('userName') ?? "Mahasiswa";
  final String? savedImage = prefs.getString('profileImage');

  runApp(
    MyApp(
      isFirstTime: isFirstTime,
      savedName: savedName,
      savedImage: savedImage,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirstTime;
  final String savedName;
  final String? savedImage;

  const MyApp({
    super.key,
    required this.isFirstTime,
    required this.savedName,
    this.savedImage,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String? _profileImagePath;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = widget.savedName;
    _profileImagePath = widget.savedImage;
  }

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  void _updateProfileImage(String path) {
    setState(() => _profileImagePath = path);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Keuangan',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: TemaAplikasi.lightTheme,
      darkTheme: TemaAplikasi.darkTheme,
      home: widget.isFirstTime
          ? const OnboardingScreen()
          : HalamanUtama(
              isDarkMode: _isDarkMode,
              toggleTheme: _toggleTheme,
              profileImagePath: _profileImagePath,
              updateImage: _updateProfileImage,
              userName: _userName,
            ),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String? profileImagePath;
  final Function(String) updateImage;
  final String userName;

  const HalamanUtama({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.profileImagePath,
    required this.updateImage,
    required this.userName,
  });

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;
  DateTime _bulanPilihan = DateTime.now(); // Default hari ini

  // Data List
  List<Transaksi> _daftarTransaksi = [];
  List<Wishlist> _daftarWishlist = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // <--- BACA DATA SAAT APLIKASI DIBUKA
  }

  // --- FUNGSI SIMPAN & BACA DATA (DATABASE SEDERHANA) ---

  // 1. Simpan ke HP
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ubah List Transaksi jadi Teks JSON
    final String transaksiJson = jsonEncode(_daftarTransaksi.map((e) => e.toJson()).toList());
    
    // Ubah List Wishlist jadi Teks JSON
    final String wishlistJson = jsonEncode(_daftarWishlist.map((e) => e.toJson()).toList());

    // Simpan
    await prefs.setString('data_transaksi', transaksiJson);
    await prefs.setString('data_wishlist', wishlistJson);
  }

  // 2. Baca dari HP
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil teks JSON
    final String? transaksiString = prefs.getString('data_transaksi');
    final String? wishlistString = prefs.getString('data_wishlist');

    setState(() {
      if (transaksiString != null) {
        // Kembalikan Teks jadi List Transaksi
        List<dynamic> jsonList = jsonDecode(transaksiString);
        _daftarTransaksi = jsonList.map((e) => Transaksi.fromJson(e)).toList();
      }
      
      if (wishlistString != null) {
        // Kembalikan Teks jadi List Wishlist
        List<dynamic> jsonList = jsonDecode(wishlistString);
        _daftarWishlist = jsonList.map((e) => Wishlist.fromJson(e)).toList();
      }
    });
  }

  // --- HITUNGAN SALDO ---

  double get _saldoSebelumnya {
    DateTime awalBulanIni = DateTime(_bulanPilihan.year, _bulanPilihan.month, 1);
    return _daftarTransaksi
        .where((tx) => tx.tanggal.isBefore(awalBulanIni))
        .fold(0.0, (saldo, item) => item.isPengeluaran ? saldo - item.jumlah : saldo + item.jumlah);
  }

  List<Transaksi> get _transaksiPerBulan {
    return _daftarTransaksi.where((tx) {
      return tx.tanggal.month == _bulanPilihan.month &&
          tx.tanggal.year == _bulanPilihan.year;
    }).toList();
  }

  double get _pemasukanBulanIni => _transaksiPerBulan
      .where((t) => !t.isPengeluaran)
      .fold(0.0, (sum, item) => sum + item.jumlah);
      
  double get _pengeluaranBulanIni => _transaksiPerBulan
      .where((t) => t.isPengeluaran)
      .fold(0.0, (sum, item) => sum + item.jumlah);
      
  double get _saldoAkhir => _saldoSebelumnya + _pemasukanBulanIni - _pengeluaranBulanIni;

  String get _saranKeuangan {
    if (_saldoAkhir < 0) return "⚠️ Defisit!";
    else if (_saldoAkhir < 100000) return "⚠️ Saldo menipis.";
    else return "✅ Aman.";
  }

  // --- MODIFIKASI FUNGSI TAMBAH/HAPUS AGAR AUTO-SAVE ---

  void _tambahTransaksiBaru(String judul, double jumlah, bool isPengeluaran, DateTime pickedDate) {
    setState(() {
      _daftarTransaksi.add(
        Transaksi(judul: judul, jumlah: jumlah, isPengeluaran: isPengeluaran, tanggal: pickedDate),
      );
    });
    _saveData(); // <--- SIMPAN SETIAP NAMBAH
  }

  void _hapusTransaksi(Transaksi transaksiYangDihapus) {
    setState(() {
      _daftarTransaksi.remove(transaksiYangDihapus);
    });
    _saveData(); // <--- SIMPAN SETIAP HAPUS
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus."), duration: Duration(seconds: 2)));
  }

  void _tambahWishlist(String nama, double harga) {
    setState(() => _daftarWishlist.add(Wishlist(namaBarang: nama, harga: harga)));
    _saveData(); // <--- SIMPAN
  }

  void _toggleStatusWishlist(int index) {
    setState(() {
      bool statusLama = _daftarWishlist[index].isTercapai;
      _daftarWishlist[index].isTercapai = !statusLama;

      if (_daftarWishlist[index].isTercapai) {
        _tambahTransaksiBaru(
          "Beli ${_daftarWishlist[index].namaBarang}",
          _daftarWishlist[index].harga,
          true,
          DateTime.now(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saldo dipotong Rp ${_daftarWishlist[index].harga.toStringAsFixed(0)}"), backgroundColor: Colors.green),
        );
      }
    });
    _saveData(); // <--- SIMPAN
  }

  void _hapusWishlist(int index) {
    setState(() => _daftarWishlist.removeAt(index));
    _saveData(); // <--- SIMPAN
  }

  // --- SISA KODE SAMA (UI) ---

  void _onFabPressed() {
    if (_selectedIndex == 2) {
      _showAddWishlistDialog();
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TambahTransaksiScreen(onTambah: _tambahTransaksiBaru)));
    }
  }

  void _showAddWishlistDialog() {
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Keinginan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: "Nama Barang")),
            TextField(controller: hargaController, decoration: const InputDecoration(labelText: "Harga (Rp)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              final nama = namaController.text;
              final harga = double.tryParse(hargaController.text) ?? 0;
              if (nama.isNotEmpty && harga > 0) {
                _tambahWishlist(nama, harga);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listHalaman = [
      Dashboard(
        saldoAkhir: _saldoAkhir,
        saldoAwal: _saldoSebelumnya,
        saranKeuangan: _saranKeuangan,
        listTransaksi: _transaksiPerBulan,
        currentMonth: _bulanPilihan,
        onMonthChanged: (val) => setState(() => _bulanPilihan = DateTime(_bulanPilihan.year, _bulanPilihan.month + val, 1)),
        listWishlist: _daftarWishlist,
        userName: widget.userName,
      ),
      RiwayatTransaksi(daftarTransaksi: _transaksiPerBulan, onHapus: _hapusTransaksi),
      WishlistScreen(
        daftarWishlist: _daftarWishlist,
        onToggleStatus: _toggleStatusWishlist,
        onDelete: _hapusWishlist,
        currentBalance: _saldoAkhir,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(['Dashboard', 'Riwayat', 'Wishlist'][_selectedIndex])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("Member Premium"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: widget.profileImagePath != null
                      ? (kIsWeb
                          ? Image.network(widget.profileImagePath!, fit: BoxFit.cover, width: 90, height: 90, errorBuilder: (c, e, s) => Image.asset('assets/mascot.gif'))
                          : Image.file(File(widget.profileImagePath!), fit: BoxFit.cover, width: 90, height: 90, errorBuilder: (c, e, s) => Image.asset('assets/mascot.gif')))
                      : Image.asset('assets/mascot.gif', fit: BoxFit.cover),
                ),
              ),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            ),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 0); }),
            ListTile(leading: const Icon(Icons.history), title: const Text('Riwayat'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 1); }),
            ListTile(leading: const Icon(Icons.card_giftcard), title: const Text('Wishlist'), onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 2); }),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Pengaturan'), onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanScreen(isDarkMode: widget.isDarkMode, onThemeChanged: widget.toggleTheme, imagePath: widget.profileImagePath, onImageChanged: widget.updateImage)));
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Wishlist'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _onFabPressed, child: const Icon(Icons.add)),
      body: listHalaman[_selectedIndex],
    );
  }
}