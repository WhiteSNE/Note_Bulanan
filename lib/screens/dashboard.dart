import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/transaksi.dart';
import '../models/wishlist.dart';

class Dashboard extends StatelessWidget {
  final double saldoAkhir;
  final String saranKeuangan;
  final List<Transaksi> listTransaksi;
  final DateTime currentMonth;
  final Function(int) onMonthChanged;
  final List<Wishlist> listWishlist;
  final double saldoAwal;
  final String userName;

  const Dashboard({
    super.key,
    required this.saldoAkhir,
    required this.saranKeuangan,
    required this.listTransaksi,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.listWishlist,
    required this.saldoAwal,
    required this.userName,
  });

  // ------------ UTILITIES ------------ //

  List<Transaksi> get _sortedList {
    final sorted = List<Transaksi>.from(listTransaksi);
    sorted.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    return sorted;
  }

  String _getMascotPath() {
    if (saldoAkhir < 0) return 'assets/defisit.gif';
    if (saldoAkhir < 500000) return 'assets/stagnan.gif';
    return 'assets/surplus.gif';
  }

  double _progressWishlist() {
    if (listWishlist.isEmpty) return 0.0;
    final achieved = listWishlist.where((w) => w.isTercapai).length;
    return achieved / listWishlist.length;
  }

  // ------------ UI SECTION BUILDERS ------------ //

  Widget _buildMascotHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(height: 100, child: Image.asset(_getMascotPath())),
        Text(
          "Halo, $userName!",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          saldoAkhir < 0
              ? "Waduh, Defisit!"
              : saldoAkhir < 500000
                  ? "Hati-hati ya..."
                  : "Keuangan Mantap!",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSaldoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Total Saldo Akhir", style: TextStyle(fontSize: 14)),
          Text(
            "Rp ${saldoAkhir.toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            "(Saldo Awal: Rp ${saldoAwal.toStringAsFixed(0)})",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              saranKeuangan,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: saldoAkhir < 0 ? Colors.red : Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN 1: Tambahkan parameter context di sini
  Widget _buildWishlistSection(BuildContext context) {
    if (listWishlist.isEmpty) return const SizedBox();

    final progressValue = _progressWishlist();
    final achieved = listWishlist.where((w) => w.isTercapai).length;
    final total = listWishlist.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        // Sekarang context dikenali karena sudah dioper
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Target Keinginan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("$achieved / $total Terbeli",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 10),

              // PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressValue == 1.0 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          // DETAIL ITEMS
          children: listWishlist.map((item) {
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                item.isTercapai
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: item.isTercapai ? Colors.green : Colors.grey,
                size: 20,
              ),
              title: Text(
                item.namaBarang,
                style: TextStyle(
                  decoration:
                      item.isTercapai ? TextDecoration.lineThrough : null,
                  color: item.isTercapai ? Colors.grey : Colors.black,
                  fontSize: 13,
                ),
              ),
              trailing: Text(
                _formatHarga(item.harga),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatHarga(double harga) {
    if (harga < 1000000) {
      return "${(harga / 1000).toStringAsFixed(0)}k";
    }
    return "${(harga / 1000000).toStringAsFixed(1)}jt";
  }

  // PERBAIKAN 2: Tambahkan parameter context di sini juga
  Widget _buildMonthFilter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        // Context sekarang dikenali
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.white),
            onPressed: () => onMonthChanged(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(currentMonth),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.white),
            onPressed: () => onMonthChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _buildGrafik() {
    final dataGrafik = _sortedList;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Grafik Harian",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),

        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: _buildChartTitles(dataGrafik),
              lineTouchData: _buildChartTouch(dataGrafik),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(dataGrafik),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AxisTitles _removeTitles() => AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );

  FlTitlesData _buildChartTitles(List<Transaksi> dataGrafik) {
    return FlTitlesData(
      rightTitles: _removeTitles(),
      topTitles: _removeTitles(),
      leftTitles: _removeTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= dataGrafik.length) {
              return const Text('');
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('d MMM').format(dataGrafik[index].tanggal),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _buildChartTouch(List<Transaksi> dataGrafik) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 10,
        getTooltipColor: (spot) => Colors.blueGrey.withValues(alpha: 0.9),
        getTooltipItems: (spots) {
          return spots.map((barSpot) {
            final index = barSpot.x.toInt();
            if (index < 0 || index >= dataGrafik.length) return null;

            final tx = dataGrafik[index];
            final date = DateFormat('d MMM HH:mm').format(tx.tanggal);

            return LineTooltipItem(
              "$date\n",
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: "Rp ${barSpot.y.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  // ------------ GRAFIK SPOTS ------------ //

  List<FlSpot> _generateSpots(List<Transaksi> data) {
    if (data.isEmpty) return [const FlSpot(0, 0)];

    double runningBalance = saldoAwal;
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final tx = data[i];
      runningBalance += tx.isPengeluaran ? -tx.jumlah : tx.jumlah;
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    return spots;
  }

  // ------------ MAIN BUILD ------------ //

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMascotHeader(),
          _buildSaldoCard(context), // Ini sudah benar
          _buildWishlistSection(context), // PERBAIKAN: Oper context ke sini
          const SizedBox(height: 20),
          _buildMonthFilter(context), // PERBAIKAN: Oper context ke sini
          _buildGrafik(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}