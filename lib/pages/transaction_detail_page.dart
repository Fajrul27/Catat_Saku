import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: themeProvider.getBackgroundColor(isDark),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: themeProvider.getTextColor(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Detail Catatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(isDark),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_rounded,
                          color: themeProvider.getTextColor(isDark),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-transaction',
                            arguments: transaction,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: transaction.type == 'income'
                                  ? [
                                      const Color(0xFF34C759),
                                      const Color(0xFF30D158),
                                    ]
                                  : [
                                      const Color(0xFF5D5FEF),
                                      const Color(0xFF8E90FF),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: (transaction.type == 'income'
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFF5D5FEF))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                transaction.type == 'income'
                                    ? 'Pemasukan'
                                    : 'Pengeluaran',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(transaction.amount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Details Section
                        _buildDetailItem(
                          icon: Icons.category_rounded,
                          label: 'Kategori',
                          value: transaction.category,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        _buildDetailItem(
                          icon: Icons.calendar_today_rounded,
                          label: 'Tanggal',
                          value: DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(transaction.date),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        _buildDetailItem(
                          icon: Icons.access_time_rounded,
                          label: 'Waktu',
                          value: DateFormat('HH:mm', 'id_ID')
                              .format(transaction.date),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 24),

                        // Notes Section
                        if (transaction.note != null &&
                            transaction.note!.isNotEmpty) ...[
                          Text(
                            'Keterangan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.getTextColor(isDark),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF7FCF7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              transaction.note!,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.getTextColor(isDark),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    size: 64,
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada keterangan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white60
                        : const Color(0xFF1B1B1B).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
