import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/main_navigation_screen.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';
import 'features/budget/presentation/providers/budget_provider.dart'; // Import baru

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()), // Daftarkan BudgetProvider
      ],
      child: const MyLoveeApp(),
    ),
  );
}

class MyLoveeApp extends StatelessWidget {
  const MyLoveeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Lovee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}