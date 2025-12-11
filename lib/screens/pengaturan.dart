import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPrefs
import 'onboarding.dart'; // Import Onboarding untuk navigasi balik

class PengaturanScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final String? imagePath;
  final Function(String) onImageChanged;

  const PengaturanScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.imagePath,
    required this.onImageChanged,
  });

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _localImagePath = widget.imagePath;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _localImagePath = pickedFile.path;
        });
        widget.onImageChanged(pickedFile.path);
      }
    } catch (e) {
      print("Error ambil gambar: $e");
    }
  }

  // --- LOGIKA RESET DATA ---
  Future<void> _resetAplikasi() async {
    // 1. Tampilkan Dialog Konfirmasi (Biar gak salah pencet)
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Hapus Semua Data?"),
        content: const Text(
          "Tindakan ini akan menghapus Nama, Foto Profil, dan Pengaturan.\n\nAplikasi akan kembali ke kondisi awal (seperti baru install).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), // Ya, Hapus
            child: const Text("Ya, Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false; // Default false kalau dialog ditutup paksa

    if (confirm) {
      // 2. Hapus Memori HP (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus nama, isFirstTime, dll.

      // 3. Restart Navigasi ke Halaman Onboarding
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false, // Hapus semua riwayat halaman sebelumnya
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // BAGIAN FOTO PROFIL
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: ClipOval(
                          child: _localImagePath != null
                              ? (kIsWeb 
                                  ? Image.network(
                                      _localImagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Image.asset('assets/profile.png'),
                                    )
                                  : Image.file(
                                      File(_localImagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Image.asset('assets/profile.png'),
                                    ))
                              : Image.asset(
                                  'assets/profile.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text("Ketuk foto untuk mengubah", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(),

          // SWITCH TEMA
          SwitchListTile(
            title: const Text("Mode Gelap (Dark Mode)"),
            subtitle: const Text("Gunakan tema gelap agar nyaman di mata"),
            value: widget.isDarkMode,
            activeTrackColor: Colors.teal,
            onChanged: (val) => widget.onThemeChanged(val),
            secondary: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          
          const Divider(),
          
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Versi Aplikasi"),
            trailing: Text("1.0.0"),
          ),

          const SizedBox(height: 50), // Jarak agar tombol ada di bawah

          // TOMBOL RESET DATA (DANGER ZONE)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetAplikasi, // Panggil fungsi reset
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text("Hapus Data & Reset Aplikasi"),
            ),
          ),
        ],
      ),
    );
  }
}