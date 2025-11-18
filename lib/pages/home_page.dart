import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;
          final accentColor = isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
          return Scaffold(
            backgroundColor: themeProvider.getBackgroundColor(isDark),
            body: SafeArea(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.history_rounded,
                                      color: themeProvider.getTextColor(isDark),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/history');
                                    },
                                  ),
                                  Text(
                                    'Catat Saku',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.getTextColor(isDark),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.settings_rounded,
                                      color: themeProvider.getTextColor(isDark),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/settings');
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Balance Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF5D5FEF),
                                      Color(0xFF8E90FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5D5FEF).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Decorative circles
                                    Positioned(
                                      top: -20,
                                      right: -20,
                                      child: Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -10,
                                      left: -10,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Saldo',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _formatCurrency(provider.balance),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.account_balance_wallet_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Container(
                                          height: 1,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.arrow_downward_rounded,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Pemasukan',
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.9),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatCurrency(provider.totalIncome),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.arrow_upward_rounded,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Pengeluaran',
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.9),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatCurrency(provider.totalExpense),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Recent Transactions Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat baru baru ini',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.getTextColor(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (provider.recentTransactions.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.receipt_long_rounded,
                                              size: 64,
                                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Belum ada transaksi',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...provider.recentTransactions.map((transaction) {
                                      return _buildTransactionItem(context, transaction, isDark);
                                    }),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      'Tekan tombol \'+\' di bawah untuk mencatat\npengeluaran atau pemasukan pertamamu.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark 
                                            ? Colors.white.withOpacity(0.5)
                                            : const Color(0xFF1B1B1B).withOpacity(0.5),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Add Button
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-transaction');
                          },
                          backgroundColor: accentColor,
                          elevation: 8,
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, bool isDark) {
    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.edit, color: Colors.white, size: 28),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe kiri - Edit
          Navigator.pushNamed(
            context,
            '/edit-transaction',
            arguments: transaction,
          );
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe kanan - Hapus
          return await _showDeleteConfirmDialog(context, transaction, isDark);
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/transaction-detail',
            arguments: transaction,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(transaction.category),
                  color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
                  size: 24,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM yyyy', 'id_ID').format(transaction.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark 
                          ? Colors.white60 
                          : const Color(0xFF1B1B1B).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(transaction.amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: transaction.type == 'income'
                    ? const Color(0xFF34C759)
                    : (isDark ? Colors.white : const Color(0xFF1B1B1B)),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, Transaction transaction, bool isDark) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Hapus Transaksi',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus transaksi "${transaction.title}"?',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF1B1B1B).withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction.id);
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop(true);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaksi berhasil dihapus'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String categoryName) {
    // Category icons matching add_transaction_page.dart
    final Map<String, IconData> categoryIcons = {
      // Expense
      'Makanan & Minuman': Icons.restaurant_rounded,
      'Transport': Icons.directions_car_rounded,
      'Belanja': Icons.shopping_bag_rounded,
      'Hiburan': Icons.movie_rounded,
      'Tagihan': Icons.receipt_long_rounded,
      'Kesehatan': Icons.medical_services_rounded,
      'Pendidikan': Icons.school_rounded,
      // Income
      'Gaji': Icons.wallet_rounded,
      'Bonus': Icons.card_giftcard_rounded,
      'Investasi': Icons.trending_up_rounded,
      'Hadiah': Icons.redeem_rounded,
      'Freelance': Icons.work_outline_rounded,
      'Penjualan': Icons.sell_rounded,
      // Default
      'Lainnya': Icons.more_horiz_rounded,
    };
    
    return categoryIcons[categoryName] ?? Icons.category_rounded;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp',
      decimalDigits:0,
    );
    return formatter.format(amount);
  }
}
