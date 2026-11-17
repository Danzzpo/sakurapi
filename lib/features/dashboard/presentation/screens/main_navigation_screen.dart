import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import '../../../transaction/presentation/screens/manual_transaction_screen.dart';
import '../../../budget/presentation/screens/tracker_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const Center(child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    const Center(child: Text('Statistik & Kesehatan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    const TrackerScreen(),
  ];

  // Fungsi untuk memunculkan Bottom Sheet Premium
  void _showAddTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indikator Drag (Handle)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Cara Mencatat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Opsi 1: Input Manual
                _buildOptionCard(
                  context,
                  icon: Icons.edit_document,
                  title: 'Input Manual',
                  subtitle: 'Catat pengeluaran atau pemasukan sendiri.',
                  onTap: () {
                    Navigator.pop(context); // Tutup Bottom Sheet
                    // Buka layar form transaksi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualTransactionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Opsi 2: Scan Nota
                _buildOptionCard(
                  context,
                  icon: Icons.document_scanner_outlined,
                  title: 'Scan Nota',
                  subtitle: 'Otomatis baca nominal dari foto struk belanja.',
                  onTap: () {
                    Navigator.pop(context); // Tutup Bottom Sheet
                    // TODO: Arahkan ke fitur kamera/OCR
                  },
                  isOutlined: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget pembantu untuk desain kartu opsi yang premium
  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : AppColors.primary.withOpacity(0.05),
          border: isOutlined ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOutlined ? const Color(0xFFF3F4F6) : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isOutlined ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionOptions(context), // Panggil Bottom Sheet di sini
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.space_dashboard_rounded, color: AppColors.primary),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.track_changes_rounded, color: AppColors.primary),
            label: 'Tracker',
          ),
        ],
      ),
    );
  }
}