import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final filteredTransactions = _getFilteredTransactions(provider.allTransactions);

        if (isIOS) {
          return _buildIOS(filteredTransactions, provider);
        }

        return _buildAndroid(filteredTransactions, provider);
      },
    );
  }

  Widget _buildAndroid(List<TransactionModel> transactions, TransactionProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          if (_selectedTab == 0 && transactions.isNotEmpty) _buildStatsHeader(transactions),
          Expanded(
            child: transactions.isEmpty ? _buildEmptyState() : _buildList(transactions, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildIOS(List<TransactionModel> transactions, TransactionProvider provider) {
    return SafeArea(
      child: Column(
        children: [
          _buildTabBar(),
          if (_selectedTab == 0 && transactions.isNotEmpty) _buildStatsHeader(transactions),
          Expanded(
            child: transactions.isEmpty ? _buildEmptyState() : _buildList(transactions, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: _selectedTab,
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Semua'),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Pemasukan'),
            ),
            2: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Pengeluaran'),
            ),
          },
          onValueChanged: (value) {
            setState(() {
              _selectedTab = value!;
            });
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Semua')),
          ButtonSegment(value: 1, label: Text('Pemasukan')),
          ButtonSegment(value: 2, label: Text('Pengeluaran')),
        ],
        selected: {_selectedTab},
        onSelectionChanged: (selection) {
          setState(() {
            _selectedTab = selection.first;
          });
        },
      ),
    );
  }

  Widget _buildStatsHeader(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final monthTransactions = transactions.where((t) =>
        t.date.month == now.month && t.date.year == now.year).toList();
    final count = monthTransactions.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart, size: 18, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Text(
            'Total: $count transaksi bulan ini',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionModel> transactions, TransactionProvider provider) {
    final grouped = _groupByDate(transactions);
    final isIOS = Platform.isIOS;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.toList()[index];
        final dateKey = entry.key;
        final items = entry.value;

        String dateLabel;
        if (dateKey == dateFormat.format(now)) {
          dateLabel = 'Hari ini';
        } else if (dateKey == dateFormat.format(yesterday)) {
          dateLabel = 'Kemarin';
        } else {
          dateLabel = dateKey;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((t) => isIOS
                ? _buildIOSListItem(t, provider)
                : _buildAndroidListItem(t, provider)),
          ],
        );
      },
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> transactions) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final Map<String, List<TransactionModel>> grouped = {};

    for (final t in transactions) {
      final dateKey = dateFormat.format(t.date);
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }

    return grouped;
  }

  Widget _buildAndroidListItem(TransactionModel transaction, TransactionProvider provider) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            const Text(
              'Hapus',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _deleteTransaction(transaction, provider),
      child: TransactionCard(
        transaction: transaction,
        showEditIcon: true,
        onTap: () => _navigateToEdit(transaction),
      ),
    );
  }

  Widget _buildIOSListItem(TransactionModel transaction, TransactionProvider provider) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            const Text(
              'Hapus',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDeleteIOS(transaction),
      onDismissed: (_) => _deleteTransaction(transaction, provider),
      child: CupertinoContextMenu(
        actions: [
          CupertinoContextMenuAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEdit(transaction);
            },
            trailingIcon: CupertinoIcons.pencil,
            child: const Text('Edit'),
          ),
          CupertinoContextMenuAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteIOS(transaction).then((confirmed) {
                if (confirmed) {
                  _deleteTransaction(transaction, provider);
                }
              });
            },
            trailingIcon: CupertinoIcons.delete,
            child: const Text('Hapus'),
          ),
        ],
        child: TransactionCard(
          transaction: transaction,
          showEditIcon: true,
          onTap: () => _navigateToEdit(transaction),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteIOS(TransactionModel transaction) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildEmptyState() {
    final isIOS = Platform.isIOS;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isIOS ? CupertinoIcons.doc_text : Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    switch (_selectedTab) {
      case 1:
        return transactions.where((t) => t.type == 'income').toList();
      case 2:
        return transactions.where((t) => t.type == 'expense').toList();
      default:
        return transactions;
    }
  }

  void _deleteTransaction(TransactionModel transaction, TransactionProvider provider) async {
    await provider.deleteTransaction(transaction.id!);

    if (mounted) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Transaksi berhasil dihapus'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaksi dihapus'),
            action: SnackBarAction(
              label: 'Batal',
              onPressed: () {
                provider.addTransaction(transaction);
              },
            ),
          ),
        );
      }
    }
  }

  void _navigateToEdit(TransactionModel transaction) {
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