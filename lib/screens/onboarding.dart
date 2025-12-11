import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'package:flutter/foundation.dart'; 
import '../main.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  
  int _currentStep = 0; 
  // Loading state untuk mencegah user klik berkali-kali saat proses simpan
  bool _isProcessing = false; 

  // FUNGSI 1: Validasi Nama
  void _lanjutKeFoto() {
    final nama = _nameController.text.trim(); // Hapus spasi di awal/akhir
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama tidak boleh kosong ya!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  // FUNGSI 2: Pilih Foto, Simpan, dan Langsung Masuk (Auto-Proceed)
  Future<void> _pickImageAndFinish() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      // Jika user membatalkan pilih foto (klik back di galeri)
      if (pickedFile == null) return;

      // Mulai Loading
      setState(() {
        _isProcessing = true; 
      });

      // --- PROSES SIMPAN DATA ---
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Simpan Nama
      await prefs.setString('userName', _nameController.text.trim());
      
      // 2. Simpan Path Foto
      await prefs.setString('profileImage', pickedFile.path);

      // 3. Tandai Selesai
      await prefs.setBool('isFirstTime', false);

      if (!mounted) return;

      // 4. Pindah Halaman
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyApp(
            isFirstTime: false,
            savedName: _nameController.text.trim(),
            savedImage: pickedFile.path, 
          ),
        ),
      );

    } catch (e) {
      // --- ERROR HANDLING ---
      print("Error saat ambil foto: $e");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat foto: $e"),
          backgroundColor: Colors.red,
        ),
      );
      
      // Matikan loading jika gagal
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // FUNGSI 3: Lewati (Tanpa Foto)
  Future<void> _lewatiTanpaFoto() async {
    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setBool('isFirstTime', false);
      // Tidak simpan 'profileImage'

      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyApp(
            isFirstTime: false,
            savedName: _nameController.text.trim(),
            savedImage: null, 
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan sistem.")),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: _currentStep == 0 ? _buildStepNama() : _buildStepFoto(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepNama() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Image.asset('assets/profile.png', height: 120),
        ),
        const SizedBox(height: 30),
        const Text("Selamat Datang!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        const Text("Mari berkenalan dulu.", style: TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 40),
        
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Siapa nama panggilanmu?",
            prefixIcon: const Icon(Icons.person, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 30),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _lanjutKeFoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Lanjut", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepFoto() {
    // Jika sedang loading (menyimpan), tampilkan spinner
    if (_isProcessing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text("Sedang menyiapkan dompetmu...", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Satu langkah lagi!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Text("Halo, ${_nameController.text}! Pilih foto profilmu.", style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 40),

        // LINGKARAN FOTO (KLIK LANGSUNG SIMPAN)
        GestureDetector(
          onTap: _pickImageAndFinish, // <--- AKSI LANGSUNG SIMPAN
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_a_photo, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text("Pilih Foto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        const Text("Otomatis masuk setelah memilih foto", style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
        const SizedBox(height: 50),

        // TOMBOL LEWATI (Hanya Teks)
        TextButton(
          onPressed: _lewatiTanpaFoto,
          child: const Text(
            "Lewati, saya pakai avatar nanti saja >",
            style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline, decorationColor: Colors.white),
          ),
        )
      ],
    );
  }
}