// Lokasi: lib/features/transaction/presentation/screens/manual_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    String formatted = cleanText.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class ManualTransactionScreen extends StatefulWidget {
  const ManualTransactionScreen({super.key});

  @override
  State<ManualTransactionScreen> createState() => _ManualTransactionScreenState();
}

class _ManualTransactionScreenState extends State<ManualTransactionScreen> {
  bool _isExpense = true;
  String _selectedAccount = 'Tunai';
  String _selectedCategory = 'Makanan & Minuman';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 1. Sumber Dana yang disederhanakan
  final List<String> _accountOptions = ['Tunai', 'E-Mbanking', 'E-Wallet'];

  // 2. Kategori yang dipisah berdasarkan jenis transaksi
  final List<String> _expenseCategories = [
    'Makanan & Minuman', 'Transportasi', 'Kebutuhan Pokok',
    'Tagihan & Utilitas', 'Hiburan & Jajan', 'Kesehatan', 'Pendidikan', 'Lainnya'
  ];
  final List<String> _incomeCategories = [
    'Gaji', 'Bonus', 'Hasil Usaha', 'Pemberian', 'Investasi', 'Lainnya'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengganti tipe transaksi beserta reset kategorinya
  void _changeTransactionType(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      // Jika beralih tipe, pastikan kategori default disesuaikan agar tidak ada nilai nyasar
      if (_isExpense) {
        if (!_expenseCategories.contains(_selectedCategory)) {
          _selectedCategory = _expenseCategories.first;
        }
      } else {
        if (!_incomeCategories.contains(_selectedCategory)) {
          _selectedCategory = _incomeCategories.first;
        }
      }
    });
  }

  void _saveTransaction() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tidak boleh kosong')));
      return;
    }

    final String cleanAmount = _amountController.text.replaceAll('.', '');
    final int amount = int.tryParse(cleanAmount) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus lebih dari 0')));
      return;
    }

    final newTransaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      // Kita tambahkan informasi sumber dana di judul sementara agar terlihat bedanya
      title: _noteController.text.isEmpty ? '$_selectedCategory ($_selectedAccount)' : '${_noteController.text} ($_selectedAccount)',
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      note: _noteController.text,
    );

    context.read<TransactionProvider>().addTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dicatat!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  void _showPicker(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == currentValue;
                    return ListTile(
                      title: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // List kategori yang aktif saat ini, ditentukan oleh status _isExpense
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catat Transaksi'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionTypeToggle(),
            const SizedBox(height: 32),
            const Center(child: Text('Nominal', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
            const SizedBox(height: 8),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CurrencyInputFormatter()],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _isExpense ? AppColors.error : AppColors.success,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'Rp ',
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _isExpense ? AppColors.error : AppColors.success),
              ),
            ),

            const SizedBox(height: 32),
            _buildDropdownField(
              label: 'Sumber Dana',
              value: _selectedAccount,
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => _showPicker('Pilih Sumber Dana', _accountOptions, _selectedAccount, (val) => setState(() => _selectedAccount = val)),
            ),
            const SizedBox(height: 16),
            // Dropdown Kategori sekarang otomatis menyesuaikan Pemasukan/Pengeluaran
            _buildDropdownField(
              label: 'Kategori',
              value: _selectedCategory,
              icon: Icons.category_outlined,
              onTap: () => _showPicker('Pilih Kategori', currentCategories, _selectedCategory, (val) => setState(() => _selectedCategory = val)),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Tanggal',
              value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _noteController,
              label: 'Catatan (Opsional)',
              hint: 'Contoh: Beli bensin motor',
              prefixIcon: const Icon(Icons.notes),
            ),
            const SizedBox(height: 40),
            CustomButton(text: 'Simpan Transaksi', onPressed: _saveTransaction),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _changeTransactionType(true), // Menggunakan fungsi khusus agar kategori direset
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExpense ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isExpense ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, color: _isExpense ? AppColors.error : AppColors.textSecondary)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _changeTransactionType(false), // Menggunakan fungsi khusus agar kategori direset
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExpense ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_isExpense ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.bold, color: !_isExpense ? AppColors.success : AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}