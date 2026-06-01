import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/udhar_provider.dart';
import '../models/udhar_model.dart';
import '../widgets/add_udhar_dialog.dart';

class UdharScreen extends ConsumerStatefulWidget {
  const UdharScreen({super.key});

  @override
  ConsumerState<UdharScreen> createState() => _UdharScreenState();
}

class _UdharScreenState extends ConsumerState<UdharScreen> {
  String _filter = 'All';
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final udharAsync = ref.watch(udharProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                }),
              ),
              title: Text('${_selectedIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.colorScheme.primaryContainer,
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                ),
              ],
            )
          : AppBar(
              title: const Text('Udhar Manager', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.colorScheme.background,
              elevation: 0,
            ),
      body: udharAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (udhars) {
          int totalGiven = 0;
          int totalTaken = 0;
          
          for (var u in udhars) {
            if (!u.isSettled) {
              if (u.type == 'gave') totalGiven += u.amount;
              if (u.type == 'took') totalTaken += u.amount;
            }
          }

          return Column(
            children: [
              _buildSummaryCard(context, totalGiven, totalTaken),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'All', label: Text('All')),
                        ButtonSegment(value: 'gave', label: Text('Gave')),
                        ButtonSegment(value: 'took', label: Text('Took')),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => _filter = newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  final filtered = _filter == 'All' ? udhars : udhars.where((u) => u.type == _filter).toList();
                  if (filtered.isEmpty) return const Center(child: Text('No transactions yet!'));
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      final isGave = u.type == 'gave';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: _selectedIds.contains(u.id) 
                                  ? BorderSide(color: theme.colorScheme.primary, width: 2)
                                  : BorderSide.none,
                            ),
                            color: _selectedIds.contains(u.id) ? theme.colorScheme.primaryContainer.withOpacity(0.5) : null,
                            child: ListTile(
                              onTap: () {
                                if (_isSelectionMode) {
                                  setState(() {
                                    if (_selectedIds.contains(u.id)) {
                                      _selectedIds.remove(u.id);
                                      if (_selectedIds.isEmpty) _isSelectionMode = false;
                                    } else {
                                      _selectedIds.add(u.id);
                                    }
                                  });
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedIds.add(u.id);
                                  });
                                }
                              },
                              leading: CircleAvatar(
                                backgroundColor: isGave ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                child: Icon(
                                  isGave ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                                  color: isGave ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                u.personName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: u.isSettled ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(u.date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (u.description != null && u.description!.isNotEmpty)
                                    Text(u.description!, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${u.amount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isGave ? Colors.green : Colors.red,
                                      decoration: u.isSettled ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      ref.read(udharNotifierProvider.notifier).toggleSettled(u.id, u.isSettled);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: u.isSettled ? Colors.grey : theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        u.isSettled ? 'Settled' : 'Settle',
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                }),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddUdharDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transactions?'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} transaction(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              for (final id in _selectedIds) {
                await ref.read(udharNotifierProvider.notifier).deleteUdhar(id);
              }
              if (mounted) {
                setState(() {
                  _selectedIds.clear();
                  _isSelectionMode = false;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalGiven, int totalTaken) {
    final theme = Theme.of(context);
    final netAmount = totalGiven - totalTaken;
    final isPositive = netAmount >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Net Balance', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '₹${netAmount.abs()}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          Text(
            isPositive ? 'You will get' : 'You have to give',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('You Gave', '₹$totalGiven', Colors.green),
              _buildMiniStat('You Took', '₹$totalTaken', Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
