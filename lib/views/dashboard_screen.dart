import 'package:flutter/material.dart';
import 'package:saku_siswa/services/storage_service.dart';

class SakuSiswaApp extends StatelessWidget {
  const SakuSiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SakuSiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF009688), // Warna Teal yang lebih modern
        scaffoldBackgroundColor: Colors.grey.shade50, // Latar belakang lebih lembut
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSaldo = 0;
  List<Map<String, dynamic>> _riwayatPengeluaran = [];

  @override
  void initState() {
    super.initState();
    // Memuat data dan memanggil setState agar UI ter-update
    muatDataLokal().then((data) {
      setState(() {
        _totalSaldo = data['saldo'];
        _riwayatPengeluaran = data['riwayat'];
      });
    });
  }

  // Menambah transaksi baru
  void _tambahPengeluaran(String judul, int nominal) {
    if (nominal <= 0 || judul.isEmpty) return;

    setState(() {
      _totalSaldo -= nominal;
      _riwayatPengeluaran.insert(0, {
        'judul': judul,
        'nominal': nominal,
        'tanggal': DateTime.now().toString().substring(0, 10),
      });
    });

    // Simpan permanen menggunakan service yang sudah kamu buat
    simpanDataLokal(_totalSaldo, _riwayatPengeluaran); 
  }

  // Modal Bottom Sheet Form Input (UI Modern)
  void _tampilkanModalInput() {
    final judulController = TextEditingController();
    final nominalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle (Garis abu-abu di atas modal)
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tambah Pengeluaran', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              )
            ),
            const SizedBox(height: 20),
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                labelText: 'Keterangan (misal: Beli Jajan)',
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal (Rp)',
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  final judul = judulController.text;
                  final nominal = int.tryParse(nominalController.text) ?? 0;
                  _tambahPengeluaran(judul, nominal);
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Pengeluaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SakuSiswa', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // CARD UI MODERN DENGAN GRADIENT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009688), Color(0xFF00695C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Sisa Uang Saku Saat Ini',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp $_totalSaldo',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 36, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() => _totalSaldo += 50000);
                      simpanDataLokal(_totalSaldo, _riwayatPengeluaran);
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Isi Uang Saku (+50rb)'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Pengeluaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            // DYNAMIC LISTVIEW
            Expanded(
              child: _riwayatPengeluaran.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Belum ada pengeluaran hari ini.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          const Text('Pertahankan hematmu! 🎉', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _riwayatPengeluaran.length,
                      itemBuilder: (context, index) {
                        final item = _riwayatPengeluaran[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_mall_outlined, color: Colors.redAccent),
                            ),
                            title: Text(item['judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(item['tanggal'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ),
                            trailing: Text(
                              '- Rp ${item['nominal']}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _tampilkanModalInput,
        icon: const Icon(Icons.add),
        label: const Text('Catat Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}