import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama: Hijau zamrud memberikan kesan finansial yang aman, stabil, dan bertumbuh.
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF047857);

  // Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Abu-abu sangat terang agar mata tidak cepat lelah
  static const Color surface = Colors.white; // Untuk card dan elemen di atas background

  // Teks
  static const Color textPrimary = Color(0xFF111827); // Hindari hitam pekat (0xFF000000) agar kontras lebih nyaman
  static const Color textSecondary = Color(0xFF6B7280);

  // Status Finansial
  static const Color success = Color(0xFF10B981); // Untuk pemasukan
  static const Color error = Color(0xFFEF4444); // Untuk pengeluaran
  static const Color warning = Color(0xFFF59E0B); // Untuk peringatan anggaran limit
}