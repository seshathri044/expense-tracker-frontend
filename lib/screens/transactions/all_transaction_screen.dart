// lib/screens/transactions/all_transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/expense_model.dart';
import '../../models/income_model.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    
    await Future.wait([
      expenseProvider.getExpenses(),
      incomeProvider.getIncomes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Transactions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 20),
            ),
            onPressed: _loadData,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(isDarkMode),
          
          Expanded(
            child: Consumer2<ExpenseProvider, IncomeProvider>(
              builder: (context, expenseProvider, incomeProvider, child) {
                if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groupedTransactions = _groupTransactionsByMonth(
                  expenseProvider.expenses,
                  incomeProvider.incomes,
                );

                if (groupedTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first transaction',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final monthData = groupedTransactions[index];
                      return _buildMonthSection(monthData, index, isDarkMode);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildFilterChip('All', Icons.list_rounded, isDarkMode),
          const SizedBox(width: 8),
          _buildFilterChip('Income', Icons.arrow_downward_rounded, isDarkMode),
          const SizedBox(width: 8),
          _buildFilterChip('Expense', Icons.arrow_upward_rounded, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isDarkMode) {
    final isSelected = _selectedFilter == label;
    final color = label == 'Income' 
        ? AppTheme.incomeGreen 
        : label == 'Expense' 
            ? AppTheme.expenseRed 
            : AppTheme.primaryColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : (isDarkMode ? const Color(0xFF16213E) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : (isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDarkMode ? AppTheme.darkTextPrimary : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSection(Map<String, dynamic> monthData, int index, bool isDarkMode) {
    final monthYear = monthData['monthYear'] as String;
    final total = monthData['total'] as double;
    final transactions = monthData['transactions'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 12,
            top: index == 0 ? 0 : 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  isDarkMode ? const Color(0xFF16213E) : Colors.white,
                  (total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      monthYear,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: total >= 0 
                        ? AppTheme.incomeGreen.withOpacity(0.15) 
                        : AppTheme.expenseRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${total >= 0 ? '+' : ''}₹${NumberFormat('#,##,##0').format(total.abs())}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        ...transactions.map((t) => _buildTransactionCard(t, isDarkMode)),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, bool isDarkMode) {
    final isExpense = transaction['type'] == 'expense';
    final emoji = transaction['emoji'] as String;
    final title = transaction['title'] as String;
    final category = transaction['category'] as String;
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;
    final color = isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}₹${NumberFormat('#,##,##0').format(amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isExpense ? 'Expense' : 'Income',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupTransactionsByMonth(
    List<Expense> expenses,
    List<Income> incomes,
  ) {
    final allTransactions = <Map<String, dynamic>>[];

    for (var expense in expenses) {
      if (_selectedFilter == 'All' || _selectedFilter == 'Expense') {
        allTransactions.add({
          'type': 'expense',
          'title': expense.description,
          'category': expense.category,
          'emoji': ExpenseCategory.getEmoji(expense.category),
          'amount': expense.amount,
          'date': expense.date,
        });
      }
    }

    for (var income in incomes) {
      if (_selectedFilter == 'All' || _selectedFilter == 'Income') {
        allTransactions.add({
          'type': 'income',
          'title': income.description,
          'category': income.source,
          'emoji': IncomeSource.getEmoji(income.source),
          'amount': income.amount,
          'date': income.date,
        });
      }
    }

    allTransactions.sort((a, b) => 
      (b['date'] as DateTime).compareTo(a['date'] as DateTime)
    );

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var transaction in allTransactions) {
      final date = transaction['date'] as DateTime;
      final key = DateFormat('yyyy-MM').format(date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(transaction);
    }

    final result = <Map<String, dynamic>>[];
    grouped.forEach((key, transactions) {
      final date = DateTime.parse('$key-01');
      final monthYear = DateFormat('MMMM yyyy').format(date);
      
      double total = 0;
      for (var t in transactions) {
        if (t['type'] == 'income') {
          total += t['amount'] as double;
        } else {
          total -= t['amount'] as double;
        }
      }

      result.add({
        'monthYear': monthYear,
        'total': total,
        'transactions': transactions,
      });
    });

    return result;
  }
}