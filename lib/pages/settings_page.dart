import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: themeProvider.getBackgroundColor(isDark),
          body: SafeArea(
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
                          Icons.arrow_back_rounded,
                          color: themeProvider.getTextColor(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Appearance Section
                        Text(
                          'Tampilan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildSettingsItem(
                          icon: Icons.brightness_6_rounded,
                          title: 'Tema',
                          subtitle: _themeSubtitle(themeProvider.themeMode),
                          isDark: isDark,
                          onTap: () {
                            _showThemeDialog(context, themeProvider);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Data Section
                        Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildSettingsItem(
                          icon: Icons.attach_money_rounded,
                          title: 'Mata Uang',
                          subtitle: 'IDR',
                          isDark: isDark,
                          onTap: () {
                            _showCurrencyDialog(context);
                          },
                        ),

                        const SizedBox(height: 10),

                        _buildSingleSettingsItem(
                          icon: Icons.cloud_upload_rounded,
                          title: 'Backup Data',
                          isDark: isDark,
                          onTap: () {
                            _handleBackup(context);
                          },
                        ),

                        const SizedBox(height: 10),

                        _buildSingleSettingsItem(
                          icon: Icons.cloud_download_rounded,
                          title: 'Restore Data',
                          isDark: isDark,
                          onTap: () {
                            _showRestoreDialog(context);
                          },
                        ),

                        const SizedBox(height: 10),

                        _buildSingleSettingsItem(
                          icon: Icons.delete_outline_rounded,
                          title: 'Reset Data',
                          isDark: isDark,
                          iconColor: Colors.red,
                          onTap: () {
                            _showResetDialog(context);
                          },
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        Text(
                          'Tentang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildSingleSettingsItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Versi Aplikasi',
                          isDark: isDark,
                          trailing: Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.getTextColor(isDark),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                        ),
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

  String _themeSubtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Terang';
      case AppThemeMode.dark:
        return 'Gelap';
      case AppThemeMode.system:
        return 'Mengikuti tema sistem';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final currentMode = themeProvider.themeMode;
        return AlertDialog(
          title: const Text('Pilih Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context: context,
                themeProvider: themeProvider,
                mode: AppThemeMode.system,
                title: 'Ikuti Tema Sistem',
                isSelected: currentMode == AppThemeMode.system,
              ),
              _buildThemeOption(
                context: context,
                themeProvider: themeProvider,
                mode: AppThemeMode.light,
                title: 'Mode Terang',
                isSelected: currentMode == AppThemeMode.light,
              ),
              _buildThemeOption(
                context: context,
                themeProvider: themeProvider,
                mode: AppThemeMode.dark,
                title: 'Mode Gelap',
                isSelected: currentMode == AppThemeMode.dark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required AppThemeMode mode,
    required String title,
    required bool isSelected,
  }) {
    return RadioListTile<AppThemeMode>(
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (value) async {
        if (value == null) return;
        await themeProvider.setThemeMode(value);
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      title: Text(title),
      secondary: Icon(
        mode == AppThemeMode.system
            ? Icons.brightness_auto_rounded
            : mode == AppThemeMode.light
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
      ),
      activeColor: const Color(0xFF5D5FEF),
      controlAffinity: ListTileControlAffinity.trailing,
      selected: isSelected,
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF1B1B1B).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSettingsItem({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7FCF7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ??
                    (isDark
                        ? const Color(0xFF8E90FF)
                        : const Color(0xFF5D5FEF)),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mata Uang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('IDR - Rupiah Indonesia'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IDR dipilih')),
                );
              },
            ),
            ListTile(
              title: const Text('USD - US Dollar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('USD (Coming Soon)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final backupData = await provider.getBackupData();

    if (backupData.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk di-backup'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show options dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Pilih metode backup:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: backupData));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data backup disalin ke clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Salin'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Share.share(
                backupData,
                subject:
                    'Backup Catat Saku - ${DateTime.now().toString().split(' ')[0]}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D5FEF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel data backup dari clipboard:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Paste backup data di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              textController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData?.text != null) {
                textController.text = clipboardData!.text!;
              }
            },
            child: const Text('Paste'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data backup kosong'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final provider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );

              final success = await provider.restoreData(textController.text);
              textController.dispose();
              Navigator.pop(context);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Data berhasil di-restore'
                        : 'Gagal restore data. Format tidak valid.',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D5FEF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data transaksi? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              provider.resetData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data telah dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
