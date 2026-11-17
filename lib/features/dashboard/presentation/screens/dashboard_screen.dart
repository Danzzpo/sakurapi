// Lokasi: lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/domain/models/transaction_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Fungsi pembantu sederhana untuk format Rupiah
  String _formatRupiah(int amount) {
    String result = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $result';
  }

  // Fungsi pembantu untuk format Tanggal sederhana (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Membaca data dari Provider.
    // Menggunakan 'watch' artinya layar ini akan otomatis digambar ulang jika ada transaksi baru.
    final txProvider = context.watch<TransactionProvider>();
    final transactions = txProvider.transactions;

    // 2. Kalkulasi Logika Keuangan
    int totalIncome = 0;
    int totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // Saldo Utama
    final int totalBalance = totalIncome - totalExpense;

    // Logika sementara Safe-to-Spend:
    // Karena kita belum membuat fitur Budget/Tagihan, untuk sementara kita asumsikan
    // 80% dari saldo saat ini adalah uang yang "aman" digunakan untuk jajan.
    final int safeToSpend = totalBalance > 0 ? (totalBalance * 0.8).toInt() : 0;
    final int dailyLimit = safeToSpend > 0 ? (safeToSpend / 30).toInt() : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              // Kartu Total Saldo Dinamis
              _buildTotalBalanceCard(totalBalance, totalIncome, totalExpense),
              const SizedBox(height: 24),

              // Kartu Safe-to-Spend Dinamis
              _buildSafeToSpendCard(safeToSpend, dailyLimit),
              const SizedBox(height: 32),

              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // List Aktivitas Terbaru Dinamis
              _buildRecentTransactions(transactions),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Selamat Pagi,', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('Danzzpo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
          radius: 24,
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(int balance, int income, int expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo (Semua Akun)', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildBalanceDetail(Icons.arrow_downward, 'Pemasukan', income, AppColors.primaryLight)),
              Expanded(child: _buildBalanceDetail(Icons.arrow_upward, 'Pengeluaran', expense, Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(IconData icon, String label, int amount, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
              Text(
                _formatRupiah(amount),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeToSpendCard(int safeAmount, int dailyLimit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Safe-to-Spend', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('Aman', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_formatRupiah(safeAmount), style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            'Estimasi sementara (80% dari saldo) untuk jajan sebelum fitur Budget aktif.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Batas Harian Disarankan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(
                '${_formatRupiah(dailyLimit)} / hari',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada transaksi bulan ini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Ambil maksimal 5 transaksi terakhir untuk ditampilkan di Dashboard
    final recentTx = transactions.take(5).toList();

    return ListView.separated(
      shrinkWrap: true, // Wajib agar ListView tidak bentrok dengan ScrollView utama
      physics: const NeverScrollableScrollPhysics(), // Scroll diatur oleh SingleChildScrollView induk
      itemCount: recentTx.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = recentTx[index];
        final isExpense = tx.type == TransactionType.expense;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              // Ikon Kategori (sementara kita pakai ikon default berdasarkan tipe)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined,
                  color: isExpense ? AppColors.error : AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              // Judul & Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tx.category} • ${_formatDate(tx.date)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Nominal
              Text(
                '${isExpense ? '-' : '+'}${_formatRupiah(tx.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? AppColors.textPrimary : AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}