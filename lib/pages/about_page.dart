import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tentang Aplikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // App Icon
                    Container(
                      width: 100,
                      height: 100,
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
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // App Name
                    const Text(
                      'Catat Saku',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D5FEF),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Version
                    Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: isDark ? Colors.white : const Color(0xFF5D5FEF),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tentang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Catat Saku adalah aplikasi pencatat keuangan yang membantu Anda melacak pengeluaran dan pemasukan harian dengan mudah dan praktis.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark ? Colors.white70 : const Color(0xFF1B1B1B).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Features
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: isDark ? Colors.white : const Color(0xFF5D5FEF),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Fitur Utama',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            '📊 Dashboard interaktif',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '💰 Pencatatan transaksi mudah',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '📈 Grafik statistik periode',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '🔄 Backup & restore data',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '🎨 Mode terang & gelap',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '📱 Antarmuka yang intuitif',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Developer Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.code_rounded,
                                color: isDark ? Colors.white : const Color(0xFF5D5FEF),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Developer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Dikembangkan dengan ❤️ menggunakan Flutter\n\n© 2025 Catat Saku by Ahmad Fajrul Ulum. All rights reserved.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark ? Colors.white70 : const Color(0xFF1B1B1B).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Footer
                    Text(
                      'Terima kasih telah menggunakan Catat Saku! 💙',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF1B1B1B).withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
