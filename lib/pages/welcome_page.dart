import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final primaryColor = isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
        final backgroundGradient = isDark
            ? [const Color(0xFF1A1A1A), const Color(0xFF101010)]
            : [const Color(0xFFF7FCF7), Colors.white];
        final textColor = themeProvider.getTextColor(isDark);
        final secondaryTextColor = themeProvider.getSecondaryTextColor(isDark);
        final illustrationColor = isDark ? const Color(0xFF1F1F2E) : const Color(0xFFE8E9F2);

        return Scaffold(
          backgroundColor: themeProvider.getBackgroundColor(isDark),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 20,
                            child: _buildStar(12, primaryColor),
                          ),
                          Positioned(
                            top: 40,
                            right: 50,
                            child: _buildStar(8, primaryColor),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 60,
                            child: _buildStar(10, primaryColor),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 30,
                            child: _buildStar(14, primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: illustrationColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 120,
                          color: primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Selamat Datang Di\nCatat Saku !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cara termudah untuk melacak\npengeluaran harian Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasSeenWelcome', true);
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'AYO MULAI !',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStar(double size, Color primaryColor) {
    return Icon(
      Icons.star,
      size: size,
      color: primaryColor.withOpacity(0.3),
    );
  }
}
