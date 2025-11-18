import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/category_icon_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _SortOption {
  final String id;
  final String label;
  final IconData icon;

  const _SortOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;
  String _activePeriod = 'monthly';
  bool _isChartCollapsed = false;
  String _searchQuery = '';
  String _selectedType = 'all';
  String _selectedCategory = 'all';
  String? _selectedTimeSort = 'newest';
  String? _selectedAmountSort;
  bool _showFilters = false;
  bool _showChart = true;

  static const List<_SortOption> _timeSortOptions = [
    _SortOption(
      id: 'newest',
      label: 'Terbaru ke Terlama',
      icon: Icons.schedule_rounded,
    ),
    _SortOption(
      id: 'oldest',
      label: 'Terlama ke Terbaru',
      icon: Icons.history_toggle_off_rounded,
    ),
  ];

  static const List<_SortOption> _amountSortOptions = [
    _SortOption(
      id: 'highest',
      label: 'Nominal Terbesar',
      icon: Icons.trending_up_rounded,
    ),
    _SortOption(
      id: 'lowest',
      label: 'Nominal Terkecil',
      icon: Icons.trending_down_rounded,
    ),
  ];

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedType != 'all' ||
      _selectedCategory != 'all' ||
      !_isDefaultSort;

  bool get _isDefaultSort =>
      (_selectedTimeSort == null || _selectedTimeSort == 'newest') &&
      _selectedAmountSort == null;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
    _scrollController.addListener(_handleScroll);
  }

  Widget _buildTypeOptionIcon(String type) {
    switch (type) {
      case 'expense':
        return const Icon(Icons.arrow_downward_rounded,
            color: Color(0xFFE53935), size: 20);
      case 'income':
        return const Icon(Icons.arrow_upward_rounded,
            color: Color(0xFF43A047), size: 20);
      case 'all':
      default:
        return const Icon(Icons.all_inclusive_rounded,
            color: Color(0xFF5D5FEF), size: 20);
    }
  }

  Widget _buildCategoryIcon(String category, bool isDark) {
    return CategoryIconHelper.buildCategoryIcon(category, isDark);
  }

  int _compareByTimeSort(Transaction a, Transaction b) {
    if (_selectedTimeSort == null || _selectedTimeSort == 'newest') {
      return 0;
    }
    switch (_selectedTimeSort) {
      case 'oldest':
        return a.date.compareTo(b.date);
      case 'newest':
      default:
        return b.date.compareTo(a.date);
    }
  }

  int _compareByAmountSort(Transaction a, Transaction b) {
    switch (_selectedAmountSort) {
      case 'highest':
        final result = b.amount.compareTo(a.amount);
        if (result != 0) return result;
        break;
      case 'lowest':
        final result = a.amount.compareTo(b.amount);
        if (result != 0) return result;
        break;
    }
    return 0;
  }

  int _compareByDefaultTime(Transaction a, Transaction b) {
    return b.date.compareTo(a.date);
  }

  void _onSortSelected(String group, String? optionId) {
    setState(() {
      if (group == 'time') {
        _selectedTimeSort = optionId;
      } else {
        _selectedAmountSort = optionId;
      }
    });
  }

  Widget _buildFilterDropdown({
    required String label,
    IconData? labelIcon,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required ThemeProvider themeProvider,
    Widget Function(String key)? leadingBuilder,
  }) {
    final cardColor = themeProvider.getCardColor(isDark);
    final textColor = themeProvider.getTextColor(isDark);
    final entries = options.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDark
                      ? const Color(0xFF8E90FF)
                      : const Color(0xFF5D5FEF),
                ),
                items: entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: _buildDropdownTile(
                          label: entry.value,
                          textColor: textColor,
                          leading: leadingBuilder?.call(entry.key),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
                selectedItemBuilder: leadingBuilder == null
                    ? null
                    : (context) => entries
                        .map(
                          (entry) => _buildDropdownTile(
                            label: entry.value,
                            textColor: textColor,
                            leading: leadingBuilder(entry.key),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required Color textColor,
    Widget? leading,
  }) {
    return Row(
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: textColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark, ThemeProvider themeProvider) {
    final textColor = themeProvider.getTextColor(isDark);
    final secondaryTextColor = themeProvider.getSecondaryTextColor(isDark);
    final cardColor = themeProvider.getCardColor(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF5D5FEF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cari berdasarkan kategori, ...',
                hintStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
              ),
              style: TextStyle(color: textColor),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
              child:
                  const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final shouldCollapse = _scrollController.offset > 120;
    if (shouldCollapse != _isChartCollapsed) {
      setState(() {
        _isChartCollapsed = shouldCollapse;
      });
    }
  }

  void _handleSearchChanged() {
    final newQuery = _searchController.text.trim();
    if (newQuery != _searchQuery) {
      setState(() {
        _searchQuery = newQuery;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: themeProvider.getBackgroundColor(isDark),
          body: SafeArea(
            child: Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, transactionProvider, categoryProvider, child) {
                final periodTransactions =
                    _buildPeriodData(transactionProvider, _activePeriod);
                final availableCategories = _collectCategories(
                  transactionProvider.sortedTransactions,
                  categoryProvider,
                );
                final filteredTransactions =
                    _filterTransactionsForList(periodTransactions);
                final accentColor =
                    isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
                final neutralBorder =
                    isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                final filterActive = _hasActiveFilters;
                final chartActive = _showChart;

                return Column(
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
                            'Riwayat',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.getTextColor(isDark),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Period Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: themeProvider.getCardColor(isDark),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildPeriodButton(
                                  'weekly', 'Mingguan', isDark),
                            ),
                            Expanded(
                              child: _buildPeriodButton(
                                  'monthly', 'Bulanan', isDark),
                            ),
                            Expanded(
                              child: _buildPeriodButton(
                                  'yearly', 'Tahunan', isDark),
                            ),
                            Expanded(
                              child: _buildPeriodButton('all', 'Semua', isDark),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildSearchField(isDark, themeProvider),
                    ),

                    const SizedBox(height: 12),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showFilters = !_showFilters;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: filterActive
                                      ? accentColor
                                      : Colors.transparent,
                                  foregroundColor:
                                      filterActive ? Colors.white : accentColor,
                                  side: BorderSide(color: accentColor),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showFilters
                                          ? Icons.filter_list_off_rounded
                                          : Icons.filter_list_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        filterActive
                                            ? 'Filter & Urutkan (Aktif)'
                                            : 'Filter & Urutkan',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showChart = !_showChart;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: chartActive
                                      ? accentColor
                                      : Colors.transparent,
                                  foregroundColor:
                                      chartActive ? Colors.white : accentColor,
                                  side: BorderSide(
                                    color: chartActive
                                        ? accentColor
                                        : neutralBorder,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      chartActive
                                          ? Icons.remove_red_eye_outlined
                                          : Icons.show_chart_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        chartActive
                                            ? 'Sembunyikan Grafik'
                                            : 'Tampilkan Grafik',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    AnimatedCrossFade(
                      firstChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildFiltersAndSort(
                          isDark,
                          themeProvider,
                          availableCategories,
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                      crossFadeState: _showFilters
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                    ),

                    SizedBox(height: _showChart ? 16 : 8),

                    if (_showChart)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isChartCollapsed
                              ? const SizedBox.shrink()
                              : Container(
                                  key: const ValueKey('chart_container'),
                                  height: 280,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(isDark ? 0.2 : 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child:
                                      _buildChart(filteredTransactions, isDark),
                                ),
                        ),
                      ),

                    SizedBox(height: _showChart ? 24 : 12),

                    // Transactions List
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 64,
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty ||
                                            _selectedType != 'all' ||
                                            _selectedCategory != 'all'
                                        ? 'Tidak ada transaksi yang cocok'
                                        : 'Belum ada transaksi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                return _buildTransactionItem(context,
                                    filteredTransactions[index], isDark);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersAndSort(
    bool isDark,
    ThemeProvider themeProvider,
    List<String> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                label: 'Jenis',
                labelIcon: Icons.swap_horiz_rounded,
                value: _selectedType,
                options: const {
                  'all': 'Semua',
                  'expense': 'Pengeluaran',
                  'income': 'Pemasukan',
                },
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedType = value;
                  });
                },
                isDark: isDark,
                themeProvider: themeProvider,
                leadingBuilder: (key) => _buildTypeOptionIcon(key),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterDropdown(
                label: 'Kategori',
                labelIcon: Icons.category_rounded,
                value: _selectedCategory,
                options: {
                  'all': 'Semua Kategori',
                  for (final category in categories) category: category,
                },
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                isDark: isDark,
                themeProvider: themeProvider,
                leadingBuilder: (key) => _buildCategoryIcon(key, isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSortPanel(isDark, themeProvider),
      ],
    );
  }

  Widget _buildSortPanel(bool isDark, ThemeProvider themeProvider) {
    final cardColor = themeProvider.getCardColor(isDark);
    final accentColor =
        isDark ? const Color(0xFF5D5FEF) : const Color(0xFF5D5FEF);
    final borderColor =
        isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF);
    final inactiveTextColor = isDark ? Colors.white70 : const Color(0xFF1B1B1B);

    Widget buildButton(
      _SortOption option,
      bool selected,
      VoidCallback onTap,
    ) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? accentColor : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? borderColor : cardColor,
                width: selected ? 1.2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option.icon,
                  size: 18,
                  color: selected ? Colors.white : inactiveTextColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : inactiveTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildRow(
      List<_SortOption> options,
      String group,
      String? selectedId,
    ) {
      final children = <Widget>[];
      for (var i = 0; i < options.length; i++) {
        final option = options[i];
        final selected = option.id == selectedId;
        children.add(
          Expanded(
            child: buildButton(
              option,
              selected,
              () => _onSortSelected(group, selected ? null : option.id),
            ),
          ),
        );
        if (i != options.length - 1) {
          children.add(const SizedBox(width: 12));
        }
      }
      return Row(children: children);
    }

    return Column(
      children: [
        buildRow(_timeSortOptions, 'time', _selectedTimeSort),
        const SizedBox(height: 12),
        buildRow(_amountSortOptions, 'amount', _selectedAmountSort),
      ],
    );
  }

  List<String> _collectCategories(
    List<Transaction> transactions,
    CategoryProvider categoryProvider,
  ) {
    final categorySet = <String>{};
    for (final transaction in transactions) {
      categorySet.add(transaction.category);
    }
    categorySet.addAll(categoryProvider.getCustomCategories('expense'));
    categorySet.addAll(categoryProvider.getCustomCategories('income'));
    final categories = categorySet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  String _buildChartDescription(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return 'Ringkasan pemasukan & pengeluaran';
    }

    switch (_activePeriod) {
      case 'weekly':
        return 'Ringkasan pemasukan & pengeluaran per minggu (7 minggu terakhir)';
      case 'monthly':
        return 'Ringkasan pemasukan & pengeluaran per bulan (6 bulan terakhir)';
      case 'yearly':
        return 'Ringkasan pemasukan & pengeluaran per tahun (5 tahun terakhir)';
      case 'all':
      default:
        final earliest = transactions
            .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
            .date
            .year;
        final latest = transactions
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
            .date
            .year;
        if (earliest == latest) {
          return 'Ringkasan pemasukan & pengeluaran per tahun (seluruh data $earliest)';
        }
        return 'Ringkasan pemasukan & pengeluaran per tahun ($earliest - $latest)';
    }
  }

  List<Transaction> _buildPeriodData(
      TransactionProvider provider, String period) {
    switch (period) {
      case 'weekly':
        return provider.getTransactionsByPeriod('weekly');
      case 'monthly':
        return provider.getTransactionsByPeriod('monthly');
      case 'yearly':
        return provider.getTransactionsByPeriod('yearly');
      case 'all':
      default:
        return provider.getTransactionsByPeriod('all');
    }
  }

  List<Transaction> _filterTransactionsForList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const [];
    }

    final filtered = _applyFilters(transactions);
    filtered.sort((a, b) {
      final amountResult = _compareByAmountSort(a, b);
      if (amountResult != 0) {
        return amountResult;
      }

      final timeResult = _compareByTimeSort(a, b);
      if (timeResult != 0) {
        return timeResult;
      }

      return _compareByDefaultTime(a, b);
    });
    return filtered;
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    if (_searchQuery.isEmpty &&
        _selectedType == 'all' &&
        _selectedCategory == 'all') {
      return [...transactions];
    }

    final lowerQuery = _searchQuery.toLowerCase();
    return transactions.where((transaction) {
      if (_selectedType != 'all' && transaction.type != _selectedType) {
        return false;
      }

      if (_selectedCategory != 'all' &&
          transaction.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final matchesQuery =
            transaction.title.toLowerCase().contains(lowerQuery) ||
                transaction.category.toLowerCase().contains(lowerQuery) ||
                (transaction.note?.toLowerCase().contains(lowerQuery) ?? false);
        if (!matchesQuery) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildPeriodButton(String period, String label, bool isDark) {
    final isActive = _activePeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activePeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF8E90FF) : const Color(0xFF5D5FEF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF1B1B1B)),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Transaction> transactions, bool isDark) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data untuk ditampilkan',
          style: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    // Group transactions based on active period
    final Map<String, double> incomeByPeriod = {};
    final Map<String, double> expenseByPeriod = {};
    final List<String> periodLabels = [];

    final now = DateTime.now();

    if (_activePeriod == 'weekly') {
      // Last 7 weeks
      for (int i = 6; i >= 0; i--) {
        final weekStart =
            now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
        final weekKey = DateFormat('d MMM', 'id_ID').format(weekStart);
        periodLabels.add(weekKey);
        incomeByPeriod[weekKey] = 0;
        expenseByPeriod[weekKey] = 0;
      }

      for (var transaction in transactions) {
        final daysDiff = now.difference(transaction.date).inDays;
        final weekIndex = 6 - (daysDiff ~/ 7);
        if (weekIndex >= 0 && weekIndex < 7) {
          final weekStart = now.subtract(
              Duration(days: now.weekday - 1 + ((6 - weekIndex) * 7)));
          final weekKey = DateFormat('d MMM', 'id_ID').format(weekStart);

          if (transaction.type == 'income') {
            incomeByPeriod[weekKey] =
                (incomeByPeriod[weekKey] ?? 0) + transaction.amount;
          } else {
            expenseByPeriod[weekKey] =
                (expenseByPeriod[weekKey] ?? 0) + transaction.amount;
          }
        }
      }
    } else if (_activePeriod == 'monthly') {
      // Last 6 months
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM', 'id_ID').format(month);
        periodLabels.add(monthKey);
        incomeByPeriod[monthKey] = 0;
        expenseByPeriod[monthKey] = 0;
      }

      for (var transaction in transactions) {
        final monthsDiff = (now.year - transaction.date.year) * 12 +
            (now.month - transaction.date.month);
        if (monthsDiff >= 0 && monthsDiff < 6) {
          final month =
              DateTime(transaction.date.year, transaction.date.month, 1);
          final monthKey = DateFormat('MMM', 'id_ID').format(month);

          if (transaction.type == 'income') {
            incomeByPeriod[monthKey] =
                (incomeByPeriod[monthKey] ?? 0) + transaction.amount;
          } else {
            expenseByPeriod[monthKey] =
                (expenseByPeriod[monthKey] ?? 0) + transaction.amount;
          }
        }
      }
    } else if (_activePeriod == 'yearly') {
      // Yearly - last 5 years
      for (int i = 4; i >= 0; i--) {
        final year = (now.year - i).toString();
        periodLabels.add(year);
        incomeByPeriod[year] = 0;
        expenseByPeriod[year] = 0;
      }

      for (var transaction in transactions) {
        final yearsDiff = now.year - transaction.date.year;
        if (yearsDiff >= 0 && yearsDiff < 5) {
          final year = transaction.date.year.toString();

          if (transaction.type == 'income') {
            incomeByPeriod[year] =
                (incomeByPeriod[year] ?? 0) + transaction.amount;
          } else {
            expenseByPeriod[year] =
                (expenseByPeriod[year] ?? 0) + transaction.amount;
          }
        }
      }
    } else {
      // All years available
      final earliest =
          transactions.reduce((a, b) => a.date.isBefore(b.date) ? a : b).date;

      for (int year = earliest.year; year <= now.year; year++) {
        final yearKey = year.toString();
        periodLabels.add(yearKey);
        incomeByPeriod[yearKey] = 0;
        expenseByPeriod[yearKey] = 0;
      }

      for (var transaction in transactions) {
        final yearKey = transaction.date.year.toString();
        if (transaction.type == 'income') {
          incomeByPeriod[yearKey] =
              (incomeByPeriod[yearKey] ?? 0) + transaction.amount;
        } else {
          expenseByPeriod[yearKey] =
              (expenseByPeriod[yearKey] ?? 0) + transaction.amount;
        }
      }
    }

    // Create chart data
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    // Calculate max value for dynamic scaling
    double maxValue = 0;
    for (int i = 0; i < periodLabels.length; i++) {
      final label = periodLabels[i];
      final income = incomeByPeriod[label] ?? 0;
      final expense = expenseByPeriod[label] ?? 0;

      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));

      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }

    // Determine scale factor and label
    double scaleFactor = 1000;
    String scaleLabel = 'Ribuan';

    if (maxValue >= 1000000000000000) {
      // Kuadrilun (1e15)
      scaleFactor = 1000000000000000;
      scaleLabel = 'Kuadrilun';
    } else if (maxValue >= 100000000000000) {
      // Ratusan Triliun (1e14)
      scaleFactor = 100000000000000;
      scaleLabel = 'Ratusan Triliun';
    } else if (maxValue >= 10000000000000) {
      // Puluhan Triliun (1e13)
      scaleFactor = 10000000000000;
      scaleLabel = 'Puluhan Triliun';
    } else if (maxValue >= 1000000000000) {
      // Triliun (1e12)
      scaleFactor = 1000000000000;
      scaleLabel = 'Triliun';
    } else if (maxValue >= 100000000000) {
      // Ratusan Milyar (1e11)
      scaleFactor = 100000000000;
      scaleLabel = 'Ratusan Milyar';
    } else if (maxValue >= 10000000000) {
      // Puluhan Milyar (1e10)
      scaleFactor = 10000000000;
      scaleLabel = 'Puluhan Milyar';
    } else if (maxValue >= 1000000000) {
      // Milyar (1e9)
      scaleFactor = 1000000000;
      scaleLabel = 'Milyar';
    } else if (maxValue >= 100000000) {
      // Ratusan Juta (1e8)
      scaleFactor = 100000000;
      scaleLabel = 'Ratusan Juta';
    } else if (maxValue >= 10000000) {
      // Puluhan Juta (1e7)
      scaleFactor = 10000000;
      scaleLabel = 'Puluhan Juta';
    } else if (maxValue >= 1000000) {
      // Jutaan (1e6)
      scaleFactor = 1000000;
      scaleLabel = 'Jutaan';
    } else if (maxValue >= 100000) {
      // Ratusan Ribu (1e5)
      scaleFactor = 100000;
      scaleLabel = 'Ratusan Ribu';
    } else if (maxValue >= 10000) {
      // Puluhan Ribu (1e4)
      scaleFactor = 10000;
      scaleLabel = 'Puluhan Ribu';
    }

    // Scale the spots
    for (int i = 0; i < incomeSpots.length; i++) {
      incomeSpots[i] = FlSpot(incomeSpots[i].x, incomeSpots[i].y / scaleFactor);
      expenseSpots[i] =
          FlSpot(expenseSpots[i].x, expenseSpots[i].y / scaleFactor);
    }

    // Calculate dynamic maxY
    double chartMaxY = (maxValue / scaleFactor * 1.2).ceilToDouble();
    if (chartMaxY < 1) chartMaxY = 1;

    double rawMaxX = (periodLabels.length - 1).toDouble();
    if (rawMaxX < 0) rawMaxX = 0;
    final double chartMaxX = _activePeriod == 'all'
        ? (rawMaxX < 1 ? 1 : rawMaxX)
        : rawMaxX.clamp(1, 6).toDouble();

    final chartDescription = _buildChartDescription(transactions);

    return Column(
      children: [
        Text(
          chartDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 12),
        // Legend and Scale
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('Pemasukan', const Color(0xFF34C759), isDark),
            const SizedBox(width: 16),
            _buildLegend('Pengeluaran', const Color(0xFF5D5FEF), isDark),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Nilai ditampilkan dalam satuan $scaleLabel',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor:
                      isDark ? Colors.black.withOpacity(0.75) : Colors.white,
                  tooltipRoundedRadius: 12,
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isIncome = spot.barIndex == 0;
                      final label = isIncome ? 'Pemasukan' : 'Pengeluaran';
                      final barColor = isIncome
                          ? const Color(0xFF34C759)
                          : const Color(0xFF5D5FEF);
                      final amountLabel =
                          _formatCompactCurrency(spot.y * scaleFactor);
                      return LineTooltipItem(
                        '$label\n$amountLabel',
                        TextStyle(
                          color: isDark ? Colors.white : barColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= periodLabels.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          periodLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF1B1B1B),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: chartMaxX,
              minY: 0,
              maxY: chartMaxY,
              lineBarsData: [
                // Income line (show first)
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF30D158)],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF34C759),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF34C759).withOpacity(0.1),
                        const Color(0xFF34C759).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Expense line
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D5FEF), Color(0xFF8E90FF)],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF5D5FEF),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5D5FEF).withOpacity(0.1),
                        const Color(0xFF5D5FEF).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Transaction transaction, bool isDark) {
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
                  color: isDark
                      ? const Color(0xFF8E90FF)
                      : const Color(0xFF5D5FEF),
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
                      DateFormat('d MMM yyyy', 'id_ID')
                          .format(transaction.date),
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

  Future<bool?> _showDeleteConfirmDialog(
      BuildContext context, Transaction transaction, bool isDark) async {
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
              color: isDark
                  ? Colors.white70
                  : const Color(0xFF1B1B1B).withOpacity(0.7),
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
    // Expense categories icons
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

  String _formatCompactCurrency(double amount) {
    final absValue = amount.abs();
    double divisor = 1;
    String suffix = '';

    if (absValue >= 1000000000000) {
      divisor = 1000000000000;
      suffix = 'T';
    } else if (absValue >= 1000000000) {
      divisor = 1000000000;
      suffix = 'M';
    } else if (absValue >= 1000000) {
      divisor = 1000000;
      suffix = 'jt';
    } else if (absValue >= 1000) {
      divisor = 1000;
      suffix = 'rb';
    }

    if (suffix.isEmpty) {
      final formatted = NumberFormat.decimalPattern('id_ID').format(absValue);
      return amount < 0 ? '-Rp $formatted' : 'Rp $formatted';
    }

    final scaled = absValue / divisor;
    String valueStr;
    if (scaled % 1 == 0) {
      valueStr = scaled.toStringAsFixed(0);
    } else if (scaled >= 100) {
      valueStr = scaled.toStringAsFixed(0);
    } else {
      valueStr = scaled.toStringAsFixed(1);
    }
    valueStr = valueStr.replaceAll(RegExp(r'\.0$'), '');

    final prefix = amount < 0 ? '-Rp ' : 'Rp ';
    return '$prefix$valueStr$suffix';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Widget _buildLegend(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : const Color(0xFF1B1B1B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
