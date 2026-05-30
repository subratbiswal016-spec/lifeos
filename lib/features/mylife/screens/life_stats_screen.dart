import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/checkin_provider.dart';

class LifeStatsScreen extends ConsumerStatefulWidget {
  const LifeStatsScreen({super.key});

  @override
  ConsumerState<LifeStatsScreen> createState() => _LifeStatsScreenState();
}

class _LifeStatsScreenState extends ConsumerState<LifeStatsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1: return '😭';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(checkinProvider);

    // Filter history based on selected day
    List<dynamic> filteredLogs = [];
    if (!state.isLoading && state.error == null) {
      if (_selectedDay != null) {
        final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        filteredLogs = state.history.where((log) => log['date'] == selectedDateString).toList();
      } else {
        filteredLogs = state.history;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('My Daily Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            color: theme.colorScheme.surface,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                if (state.history.isEmpty) return [];
                final dateStr = DateFormat('yyyy-MM-dd').format(day);
                return state.history.where((log) => log['date'] == dateStr).toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (isSameDay(_selectedDay, selectedDay)) {
                    _selectedDay = null; // Deselect to view all
                  } else {
                    _selectedDay = selectedDay;
                  }
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // Logs List
          Expanded(
            child: state.isLoading && state.history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!, style: TextStyle(color: theme.colorScheme.error)))
                    : RefreshIndicator(
                        onRefresh: () => ref.read(checkinProvider.notifier).fetchHistory(),
                        child: filteredLogs.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Iconsax.calendar_remove, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                                          const SizedBox(height: 16),
                                          Text(
                                            _selectedDay == null ? 'No logs recorded yet.' : 'No logs for this date.', 
                                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24.0),
                                itemCount: filteredLogs.length,
                                itemBuilder: (context, index) {
                                  final log = filteredLogs[index];
                                  final date = log['date'] ?? '';
                                  final mood = log['mood'] ?? 3;
                                  final sleep = log['sleepHours'] ?? 0;
                                  final money = log['moneySpent'] ?? 0;
                                  final note = log['note'] ?? '';

                                  return FadeInUp(
                                    delay: Duration(milliseconds: 100 * index),
                                    child: InkWell(
                                      onTap: () {
                                        _showLogDetails(context, theme, log, date, _getMoodEmoji(mood));
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  date,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Text(
                                                  _getMoodEmoji(mood),
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                _buildStatItem(theme, Iconsax.moon, '${sleep}h Sleep', Colors.indigo),
                                                _buildStatItem(theme, Iconsax.wallet, '₹$money Spent', Colors.green),
                                                _buildStatItem(theme, Iconsax.battery_charging, 'Energy: ${log['energyLevel'] ?? 50}%', Colors.orange),
                                              ],
                                            ),
                                            if (note.isNotEmpty) ...[
                                              const SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  note,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontStyle: FontStyle.italic),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showLogDetails(BuildContext context, ThemeData theme, dynamic log, String date, String moodEmoji) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(moodEmoji, style: const TextStyle(fontSize: 28)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.moon, color: Colors.indigo),
                title: const Text('Sleep'),
                trailing: Text('${log['sleepHours'] ?? 0} hours', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Iconsax.battery_charging, color: Colors.orange),
                title: const Text('Energy Level'),
                trailing: Text('${log['energyLevel'] ?? 50}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Iconsax.wallet, color: Colors.green),
                title: const Text('Money Spent'),
                trailing: Text('₹${log['moneySpent'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (log['spendCategory'] != null && log['spendCategory'].toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Iconsax.tag, color: Colors.blue),
                  title: const Text('Category'),
                  trailing: Text(log['spendCategory'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              if (log['weather'] != null && log['weather'].toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Iconsax.cloud_sunny, color: Colors.amber),
                  title: const Text('Weather'),
                  trailing: Text(log['weather'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              if (log['note'] != null && log['note'].toString().isNotEmpty) ...[
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Notes', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log['note'],
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontStyle: FontStyle.italic),
                  ),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
