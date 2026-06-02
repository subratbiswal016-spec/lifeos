import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../providers/expense_provider.dart';
import '../models/expense_model.dart';
import '../widgets/add_expense_dialog.dart';
import '../../../core/widgets/glass_container.dart';

class ExpenseDashboardScreen extends ConsumerStatefulWidget {
  const ExpenseDashboardScreen({super.key});

  @override
  ConsumerState<ExpenseDashboardScreen> createState() => _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState extends ConsumerState<ExpenseDashboardScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncData = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Wallet', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (data) {
          final expenses = data['expenses'] as List<Expense>;
          final budget = data['monthlyBudget'] as double;
          
          final expenseOnly = expenses.where((e) => e.type == 'expense').toList();
          final incomeOnly = expenses.where((e) => e.type == 'income').toList();
          final totalSpent = expenseOnly.fold(0.0, (sum, e) => sum + e.amount);
          final totalIncome = incomeOnly.fold(0.0, (sum, e) => sum + e.amount);
          final balance = totalIncome - totalSpent;
          
          final categoryTotals = <String, double>{};
          for (var e in expenseOnly) {
            categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
          }

          final colors = [
            const Color(0xFF6C63FF),
            const Color(0xFFFF6584),
            const Color(0xFF38B2AC),
            const Color(0xFFF6AD55),
            const Color(0xFF9F7AEA),
            const Color(0xFFECC94B),
          ];

          final pieSections = categoryTotals.entries.toList().asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final isTouched = idx == touchedIndex;
            final color = colors[idx % colors.length];
            return PieChartSectionData(
              value: entry.value,
              title: isTouched ? '₹${entry.value.toStringAsFixed(0)}' : entry.key,
              color: color,
              radius: isTouched ? 60.0 : 50.0,
              titleStyle: TextStyle(fontSize: isTouched ? 12 : 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(expensesProvider.notifier).fetchExpenses();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Card
                  FadeInDown(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      color: totalSpent > budget && budget > 0 
                          ? Colors.red.withOpacity(0.1) 
                          : theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: totalSpent > budget && budget > 0 
                            ? Colors.red.withOpacity(0.3) 
                            : theme.colorScheme.primary.withOpacity(0.3)
                      ),
                      child: Column(
                        children: [
                          const Text('Total Spent this Month', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totalSpent.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: totalSpent > budget && budget > 0 ? Colors.red : theme.colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Income', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('+ ₹${totalIncome.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Balance', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('₹${balance.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.green : Colors.red)),
                                ],
                              ),
                            ],
                          ),
                          if (budget > 0) ...[
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            const SizedBox(height: 8),
                            Text(
                              'Monthly Budget: ₹${budget.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Remaining Amount: ₹${(budget - totalSpent).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold,
                                color: (budget - totalSpent) >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            if (totalSpent > budget)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning, color: Colors.red, size: 16),
                                    SizedBox(width: 8),
                                    Text('Budget Exceeded!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              )
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Chart
                  if (pieSections.isNotEmpty) ...[
                    FadeInUp(
                      child: Text('Spending Breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: pieSections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Recent Transactions
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text('Recent Transactions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),

                  if (expenses.isEmpty)
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Iconsax.empty_wallet, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text('No transactions this month', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...expenses.map((expense) {
                      final isIncome = expense.type == 'income';
                      return FadeInUp(
                        child: Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: isDark ? Colors.grey[900] : Colors.white,
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isIncome ? Colors.green.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isIncome ? Iconsax.arrow_down : Iconsax.arrow_up_2, 
                                  color: isIncome ? Colors.green : theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (expense.note != null && expense.note!.isNotEmpty)
                                    Text(expense.note!, style: const TextStyle(fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(expense.date),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${isIncome ? '+' : '-'}₹${expense.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 80), // Prevent FAB from blocking last transaction
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddExpenseDialog(),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
