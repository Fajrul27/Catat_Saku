import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/category_icon_helper.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/category_provider.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionPage({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _KeepAliveChild extends StatefulWidget {
  final WidgetBuilder builder;

  const _KeepAliveChild({required this.builder});

  @override
  State<_KeepAliveChild> createState() => _KeepAliveChildState();
}

class _KeepAliveChildState extends State<_KeepAliveChild>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context);
  }

  @override
  bool get wantKeepAlive => true;
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late String _transactionType;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _selectedCategory;
  final Map<String, String?> _selectedCategoryByType = {
    'expense': null,
    'income': null,
  };
  late PageController _pageController;
  late int _currentPage;
  final TextEditingController _customCategoryController =
      TextEditingController();

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

  Map<String, IconData> _buildCurrentCategories(
      CategoryProvider categoryProvider) {
    final base = _transactionType == 'expense'
        ? Map<String, IconData>.from(_expenseCategories)
        : Map<String, IconData>.from(_incomeCategories);
    for (final name in categoryProvider.getCustomCategories(_transactionType)) {
      base[name] = Icons.label_rounded;
    }
    return base;
  }

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transaction.type;
    final initialAmount = widget.transaction.amount;
    final formattedAmount = NumberFormat('#,###', 'id_ID')
        .format(initialAmount)
        .replaceAll(',', '.');
    _amountController = TextEditingController(
      text: formattedAmount,
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedDate = widget.transaction.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.transaction.date);
    _selectedCategory = widget.transaction.category;
    _selectedCategoryByType[_transactionType] = _selectedCategory;
    _currentPage = _transactionType == 'expense' ? 0 : 1;
    _pageController = PageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      if (_selectedCategory != null) {
        final existingMap = _transactionType == 'expense'
            ? _expenseCategories
            : _incomeCategories;
        final name = _selectedCategory!;
        if (!existingMap.containsKey(name) &&
            !categoryProvider.containsCategory(_transactionType, name)) {
          categoryProvider.addCustomCategory(_transactionType, name);
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    _pageController.dispose();
    super.dispose();
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

  Future<void> _updateTransaction() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amountText = _amountController.text.replaceAll('.', '');
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(amountText);

    final DateTime combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedTransaction = Transaction(
      id: widget.transaction.id,
      title: _selectedCategory!,
      amount: amount,
      date: combinedDateTime,
      category: _selectedCategory!,
      type: _transactionType,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(updatedTransaction);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil diperbarui'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, updatedTransaction);
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
                          Icons.arrow_back_rounded,
                          color: themeProvider.getTextColor(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Edit Catatan',
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0.0),
                  child: _buildTypeSelector(isDark, themeProvider),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    children: [
                      _buildTransactionForm(
                          isDark, themeProvider, categoryProvider),
                      _buildTransactionForm(
                          isDark, themeProvider, categoryProvider),
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
  ) {
    final currentCategories = _buildCurrentCategories(categoryProvider);
    return _KeepAliveChild(
      builder: (childContext) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountInput(isDark, themeProvider),
            const SizedBox(height: 20),
            _buildCategoryDropdown(
                isDark, themeProvider, currentCategories, categoryProvider),
            const SizedBox(height: 12),
            _buildAddCategoryButton(isDark, themeProvider, categoryProvider),
            const SizedBox(height: 12),
            _buildDateInput(childContext, isDark, themeProvider),
            const SizedBox(height: 12),
            _buildTimeInput(childContext, isDark, themeProvider),
            const SizedBox(height: 12),
            _buildNoteInput(isDark, themeProvider),
            const SizedBox(height: 24),
            _buildUpdateButton(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int page) {
    final newType = page == 0 ? 'expense' : 'income';
    setState(() {
      _currentPage = page;
      if (_transactionType != newType) {
        _transactionType = newType;
        _selectedCategory = _selectedCategoryByType[newType];
      }
    });
  }

  Widget _buildTypeSelector(bool isDark, ThemeProvider themeProvider) {
    final indicatorColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: themeProvider.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final indicatorWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final page = _pageController.hasClients
                      ? _pageController.page ?? _currentPage.toDouble()
                      : _currentPage.toDouble();
                  final clampedPage = page.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(clampedPage * indicatorWidth, 0),
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
    );
  }

  Widget _buildAmountInput(bool isDark, ThemeProvider themeProvider) {
    return Container(
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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
              cursorColor:
                  isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: themeProvider.getTextColor(isDark).withOpacity(0.3),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(
    bool isDark,
    ThemeProvider themeProvider,
    Map<String, IconData> currentCategories,
    CategoryProvider categoryProvider,
  ) {
    final selectedForType = _selectedCategoryByType[_transactionType];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedForType != null
              ? (isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF))
              : Colors.transparent,
          width: selectedForType != null ? 2 : 0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedForType,
          hint: Row(
            children: [
              Icon(
                Icons.category_rounded,
                color:
                    isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
              _selectedCategoryByType[_transactionType] = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton(
    bool isDark,
    ThemeProvider themeProvider,
    CategoryProvider categoryProvider,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () =>
            _showCustomCategoryDialog(isDark, themeProvider, categoryProvider),
        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF34C759)),
        label: const Text(
          'Tambah Kategori Baru',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF34C759),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
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
              color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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
              color: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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
    return TextField(
      controller: _noteController,
      maxLines: 4,
      cursorColor: isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF),
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

  Widget _buildUpdateButton(bool isDark) {
    final accentColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _updateTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Perbarui Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  void _switchType(String type) {
    final targetPage = type == 'expense' ? 0 : 1;
    if (_currentPage == targetPage) return;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _showCustomCategoryDialog(
    bool isDark,
    ThemeProvider themeProvider,
    CategoryProvider categoryProvider,
  ) async {
    final backgroundColor = themeProvider.getBackgroundColor(isDark);
    final textColor = themeProvider.getTextColor(isDark);
    final secondaryTextColor = themeProvider.getSecondaryTextColor(isDark);
    final cursorColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
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
              backgroundColor: const Color(0xFF5D5FEF),
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
}

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

    final formatter = NumberFormat('#,###', 'id_ID');
    final newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
