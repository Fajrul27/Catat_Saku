import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/category_icon_helper.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  String _transactionType = 'expense';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedCategory;
  final Map<String, String?> _selectedCategoryByType = {
    'expense': null,
    'income': null,
  };
  final TextEditingController _customCategoryController =
      TextEditingController();

  // Predefined categories with icons
  final Map<String, IconData> _expenseCategories = {
    'Makanan & Minuman': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.movie_rounded,
    'Tagihan': Icons.receipt_long_rounded,
    'Kesehatan': Icons.medical_services_rounded,
    'Pendidikan': Icons.school_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  final Map<String, IconData> _incomeCategories = {
    'Gaji': Icons.wallet_rounded,
    'Bonus': Icons.card_giftcard_rounded,
    'Investasi': Icons.trending_up_rounded,
    'Hadiah': Icons.redeem_rounded,
    'Freelance': Icons.work_outline_rounded,
    'Penjualan': Icons.sell_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _amountController.text = '0';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final newType = page == 0 ? 'expense' : 'income';
    if (_currentPage == page && _transactionType == newType) return;
    setState(() {
      _currentPage = page;
      _transactionType = newType;
      _selectedCategory = _selectedCategoryByType[newType];
    });
  }

  void _switchType(String type) {
    final targetPage = type == 'expense' ? 0 : 1;
    if (_currentPage == targetPage) return;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Map<String, IconData> _buildCurrentCategories(
      String type, CategoryProvider categoryProvider) {
    final base = type == 'expense'
        ? Map<String, IconData>.from(_expenseCategories)
        : Map<String, IconData>.from(_incomeCategories);
    for (final name in categoryProvider.getCustomCategories(type)) {
      base[name] = Icons.label_rounded;
    }
    return base;
  }

  Future<void> _showCustomCategoryDialog(
    bool isDark,
    ThemeProvider themeProvider,
    CategoryProvider categoryProvider,
  ) async {
    final backgroundColor = themeProvider.getBackgroundColor(isDark);
    final textColor = themeProvider.getTextColor(isDark);
    final secondaryTextColor = themeProvider.getSecondaryTextColor(isDark);
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    final cursorColor = accentColor;
    final borderColor = cursorColor.withOpacity(0.3);

    final customCategory = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Tambah Kategori Baru',
          style: TextStyle(color: textColor),
        ),
        content: TextField(
          controller: _customCategoryController,
          style: TextStyle(color: textColor),
          cursorColor: cursorColor,
          decoration: InputDecoration(
            hintText: 'Masukkan nama kategori',
            hintStyle: TextStyle(color: secondaryTextColor),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cursorColor, width: 2)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_customCategoryController.text.isNotEmpty) {
                Navigator.pop(dialogContext, _customCategoryController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (customCategory != null && customCategory.isNotEmpty) {
      await categoryProvider.addCustomCategory(
          _transactionType, customCategory);
      if (!mounted) return;
      setState(() {
        _selectedCategory = customCategory;
        _selectedCategoryByType[_transactionType] = customCategory;
      });
    }

    _customCategoryController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF8E90FF),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF5D5FEF),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1B1B1B),
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF8E90FF),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF5D5FEF),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1B1B1B),
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedCategory!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi jumlah dan kategori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll('.', ''));
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine date and time
    final DateTime combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _selectedCategory!,
      amount: amount,
      date: combinedDateTime,
      category: _selectedCategory!,
      type: _transactionType,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (!mounted) return;
    await Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(transaction);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil ditambahkan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, CategoryProvider>(
      builder: (context, themeProvider, categoryProvider, _) {
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
                          Icons.close_rounded,
                          color: themeProvider.getTextColor(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Tambah Catatan',
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

                // Type Selector with swipe indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: themeProvider.getCardColor(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final indicatorWidth = constraints.maxWidth / 2;
                        final indicatorColor = isDark
                            ? const Color(0xFF8E90FF)
                            : const Color(0xFF5D5FEF);
                        return Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                final page = _pageController.hasClients
                                    ? _pageController.page ??
                                        _currentPage.toDouble()
                                    : _currentPage.toDouble();
                                final clampedPage = page.clamp(0.0, 1.0);
                                return Transform.translate(
                                  offset:
                                      Offset(clampedPage * indicatorWidth, 0),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: indicatorWidth,
                                decoration: BoxDecoration(
                                  color: indicatorColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTypeButton(
                                    'expense',
                                    'Pengeluaran',
                                    _transactionType == 'expense',
                                    isDark,
                                  ),
                                ),
                                Expanded(
                                  child: _buildTypeButton(
                                    'income',
                                    'Pemasukan',
                                    _transactionType == 'income',
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    children: [
                      _buildTransactionForm(
                          isDark, themeProvider, categoryProvider, 'expense'),
                      _buildTransactionForm(
                          isDark, themeProvider, categoryProvider, 'income'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionForm(
    bool isDark,
    ThemeProvider themeProvider,
    CategoryProvider categoryProvider,
    String type,
  ) {
    final currentCategories = _buildCurrentCategories(type, categoryProvider);
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    final isActiveType = _transactionType == type;
    final selectedForType = _selectedCategoryByType[type];

    return _KeepAliveWidget(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeProvider.getCardColor(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorInputFormatter(),
                      ],
                      cursorColor: accentColor,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: themeProvider
                              .getTextColor(isDark)
                              .withOpacity(0.3),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category Dropdown
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: themeProvider.getCardColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActiveType && selectedForType != null
                      ? accentColor
                      : Colors.transparent,
                  width: isActiveType && selectedForType != null ? 2 : 0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedForType,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Pilih kategori',
                        style: TextStyle(
                          fontSize: 15,
                          color: themeProvider.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                  isExpanded: true,
                  dropdownColor:
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: accentColor,
                  ),
                  items: currentCategories.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          CategoryIconHelper.buildCategoryIcon(
                            entry.key,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 15,
                              color: themeProvider.getTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isActiveType
                      ? (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            _selectedCategoryByType[_transactionType] =
                                newValue;
                          });
                        }
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showCustomCategoryDialog(
                    isDark, themeProvider, categoryProvider),
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFF34C759)),
                label: const Text(
                  'Tambah Kategori Baru',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34C759),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Date Input
            _buildDateInput(context, isDark, themeProvider),
            const SizedBox(height: 12),
            _buildTimeInput(context, isDark, themeProvider),
            const SizedBox(height: 12),
            _buildNoteInput(isDark, themeProvider),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: themeProvider.getCardColor(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    return InkWell(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: themeProvider.getCardColor(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedTime.format(context),
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput(bool isDark, ThemeProvider themeProvider) {
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    return TextField(
      controller: _noteController,
      maxLines: 4,
      cursorColor: accentColor,
      style: TextStyle(
        color: themeProvider.getTextColor(isDark),
      ),
      decoration: InputDecoration(
        hintText: 'Keterangan (Opsional)',
        hintStyle: TextStyle(
          color: themeProvider.getSecondaryTextColor(isDark),
          fontSize: 15,
        ),
        filled: true,
        fillColor: themeProvider.getCardColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildTypeButton(
      String type, String label, bool isActive, bool isDark) {
    return GestureDetector(
      onTap: () => _switchType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF1B1B1B)),
          ),
        ),
      ),
    );
  }
}

class _KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const _KeepAliveWidget({required this.child});

  @override
  State<_KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<_KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

// Thousands separator formatter for currency input
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,###');
    final newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
