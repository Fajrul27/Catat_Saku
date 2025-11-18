import 'package:flutter/material.dart';

class CategoryIconHelper {
  static const Map<String, IconData> _categoryIconMap = {
    'makan': Icons.restaurant_rounded,
    'food': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'drink': Icons.local_cafe_rounded,
    'transport': Icons.directions_bus_rounded,
    'transportasi': Icons.directions_bus_rounded,
    'bbm': Icons.local_gas_station_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'tagihan': Icons.receipt_long_rounded,
    'bill': Icons.receipt_long_rounded,
    'listrik': Icons.flash_on_rounded,
    'air': Icons.water_drop_rounded,
    'internet': Icons.wifi_rounded,
    'hiburan': Icons.movie_creation_rounded,
    'entertain': Icons.movie_creation_rounded,
    'pendidikan': Icons.school_rounded,
    'edu': Icons.school_rounded,
    'kesehatan': Icons.health_and_safety_rounded,
    'health': Icons.health_and_safety_rounded,
    'gaji': Icons.payments_rounded,
    'salary': Icons.payments_rounded,
    'bonus': Icons.card_giftcard_rounded,
    'invest': Icons.trending_up_rounded,
    'tabungan': Icons.savings_rounded,
    'hadiah': Icons.card_giftcard_rounded,
    'donasi': Icons.volunteer_activism_rounded,
    'lain': Icons.label_rounded,
  };

  static Widget buildCategoryIcon(String category, bool isDark) {
    if (category == 'all') {
      return Icon(
        Icons.apps_rounded,
        color: isDark ? Colors.white70 : const Color(0xFF5D5FEF),
        size: 20,
      );
    }

    final lower = category.toLowerCase();
    final iconData = _categoryIconMap.entries
        .firstWhere(
          (entry) => lower.contains(entry.key),
          orElse: () => const MapEntry('', Icons.label_rounded),
        )
        .value;

    Color resolveColor() {
      if (lower.contains('makan') || lower.contains('food')) {
        return const Color(0xFFFF7043);
      }
      if (lower.contains('transport') || lower.contains('transportasi')) {
        return const Color(0xFF29B6F6);
      }
      if (lower.contains('belanja') || lower.contains('shopping')) {
        return const Color(0xFFE91E63);
      }
      if (lower.contains('tagihan') || lower.contains('bill')) {
        return const Color(0xFF5D5FEF);
      }
      if (lower.contains('hiburan') || lower.contains('entertain')) {
        return const Color(0xFFAB47BC);
      }
      if (lower.contains('pendidikan') || lower.contains('edu')) {
        return const Color(0xFF26A69A);
      }
      if (lower.contains('kesehatan') || lower.contains('health')) {
        return const Color(0xFFEF5350);
      }
      if (lower.contains('gaji') || lower.contains('salary')) {
        return const Color(0xFF43A047);
      }
      if (lower.contains('invest') || lower.contains('tabungan')) {
        return const Color(0xFFFFA726);
      }
      if (lower.contains('bonus') || lower.contains('hadiah')) {
        return const Color(0xFF8E24AA);
      }
      if (lower.contains('donasi')) {
        return const Color(0xFFFB8C00);
      }
      return isDark ? Colors.white70 : const Color(0xFF8E8E93);
    }

    final displayColor = resolveColor();

    return CircleAvatar(
      radius: 14,
      backgroundColor: displayColor.withOpacity(0.18),
      child: Icon(
        iconData,
        color: displayColor,
        size: 18,
      ),
    );
  }
}
