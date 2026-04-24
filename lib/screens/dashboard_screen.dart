import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/history_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final currencyFormat = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        final balance = provider.totalBalance;
        final income = provider.monthlyIncome;
        final expense = provider.monthlyExpense;

        final isIOS = Platform.isIOS;
        final monthFormat = DateFormat('MMMM', 'id_ID');
        final currentMonth = monthFormat.format(DateTime.now());
        final isDark = Theme.of(context).brightness == Brightness.dark;

        Widget body = RefreshIndicator(
          onRefresh: () => provider.loadTransactions(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!provider.isOnline) _buildOfflineBanner(isIOS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isIOS
                          ? [const Color(0xFF34C759), const Color(0xFF30B350)]
                          : [const Color(0xFF4CAF50), const Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormat.format(balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currentMonth,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isIOS ? CupertinoIcons.money_dollar_circle_fill : Icons.account_balance_wallet,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isIOS
                              ? const Color(0xFFE8F5E9)
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isIOS
                                  ? CupertinoIcons.arrow_down_circle_fill
                                  : Icons.arrow_downward,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(income),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isIOS
                              ? const Color(0xFFFFEBEE)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isIOS
                                  ? CupertinoIcons.arrow_up_circle_fill
                                  : Icons.arrow_upward,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(expense),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (isIOS) {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 14,
                              color: isIOS ? CupertinoColors.activeBlue : const Color(0xFF4CAF50),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: isIOS ? CupertinoColors.activeBlue : const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator.adaptive())
                else if (provider.allTransactions.isEmpty)
                  _buildEmptyState(context, isIOS)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.getRecentTransactions(5).length,
                    itemBuilder: (context, index) {
                      final transactions = provider.getRecentTransactions(5);
                      return TransactionCard(
                        transaction: transactions[index],
                        onTap: () => _navigateToEdit(context, transactions[index]),
                      );
                    },
                  ),
              ],
            ),
          ),
        );

        if (isIOS) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Personal Finance'),
            ),
            child: SafeArea(child: body),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal Finance'),
            centerTitle: true,
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: themeProvider.toggleTheme,
                  tooltip: themeProvider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                ),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildOfflineBanner(bool isIOS) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isIOS ? CupertinoIcons.wifi_slash : Icons.wifi_off,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Tidak ada koneksi internet',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isIOS) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIOS ? CupertinoIcons.doc_text : Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + untuk mulai mencatat keuanganmu',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  isIOS
                      ? CupertinoPageRoute(builder: (_) => const AddTransactionScreen())
                      : MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, TransactionModel transaction) {
    if (Platform.isIOS) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => AddTransactionScreen(
            existingTransaction: transaction,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddTransactionScreen(
            existingTransaction: transaction,
          ),
        ),
      );
    }
  }
}