// lib/screens/transactions/widgets/transaction_list_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/expense_model.dart';
import '../../../models/income_model.dart';

class TransactionListView extends StatelessWidget {
  final List<Expense> expenses;
  final List<Income> incomes;

  const TransactionListView({
    super.key,
    required this.expenses,
    required this.incomes,
  });

  @override
  Widget build(BuildContext context) {
    // Combine and group transactions by month
    final groupedTransactions = _groupTransactionsByMonth();

    if (groupedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final monthData = groupedTransactions[index];
        return _buildMonthSection(context, monthData);
      },
    );
  }

  Widget _buildMonthSection(BuildContext context, Map<String, dynamic> monthData) {
    final monthYear = monthData['monthYear'] as String;
    final total = monthData['total'] as double;
    final transactions = monthData['transactions'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Header (GPay style)
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYear,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: total >= 0 ? AppTheme.incomeGreen.withOpacity(0.1) : AppTheme.expenseRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${total >= 0 ? '+' : ''}₹${NumberFormat('#,##,##0').format(total)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: total >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Transactions
        ...transactions.map((transaction) => _buildTransactionCard(transaction)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final emoji = transaction['emoji'] as String;
    final title = transaction['title'] as String;
    final category = transaction['category'] as String;
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;
    final color = isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                category,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Text(
                ' • ${DateFormat('d MMM').format(date)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}₹${NumberFormat('#,##,##0').format(amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupTransactionsByMonth() {
    // Combine all transactions
    final allTransactions = <Map<String, dynamic>>[];

    for (var expense in expenses) {
      allTransactions.add({
        'type': 'expense',
        'title': expense.description,
        'category': expense.category,
        'emoji': ExpenseCategory.getEmoji(expense.category),
        'amount': expense.amount,
        'date': expense.date,
      });
    }

    for (var income in incomes) {
      allTransactions.add({
        'type': 'income',
        'title': income.description,
        'category': income.source,
        'emoji': IncomeSource.getEmoji(income.source),
        'amount': income.amount,
        'date': income.date,
      });
    }

    // Sort by date (newest first)
    allTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Group by month
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var transaction in allTransactions) {
      final date = transaction['date'] as DateTime;
      final key = DateFormat('yyyy-MM').format(date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(transaction);
    }

    // Convert to list with month totals
    final result = <Map<String, dynamic>>[];
    grouped.forEach((key, transactions) {
      final date = DateTime.parse('$key-01');
      final monthYear = DateFormat('MMMM yyyy').format(date);
      
      // Calculate month total (income - expense)
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