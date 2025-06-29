import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_header.dart';
import 'task_form_screen.dart';
import 'stats_screen.dart';
import 'preset_routines_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/notification_service.dart';
import '../services/motivation_service.dart';
import '../../main.dart' show scheduleDailyMotivationalNotifications;
import 'dart:convert';
import 'package:http/http.dart' as http;

// HomeScreen: schermata principale dell'app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  UserStats _userStats = UserStats.initial;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carica dati utente e quest dalla memoria.
  Future<void> _loadData() async {
    final tasks = await StorageService.getTasks();
    final stats = await StorageService.getUserStats();
    setState(() {
      _tasks = tasks;
      _userStats = stats;
    });
  }

  // Una "computed property" che filtra la lista completa delle quest per restituire solo quelle programmate per oggi.
  List<Task> get _todayTasks {
    final today = DateTime.now();
    // Compara anno, mese e giorno per trovare le quest di oggi.
    return _tasks.where((task) =>
        task.date.year == today.year &&
        task.date.month == today.month &&
        task.date.day == today.day).toList();
  }

  // Calcola il numero di quest completate oggi.
  int get _completedToday => _todayTasks.where((task) => task.completed).length;

  // Segna una quest come completata.
  Future<void> _completeTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final task = _tasks[idx];
    if (task.completed) return;
    final updatedTask = task.copyWith(completed: true);
    setState(() {
      _tasks[idx] = updatedTask;
    });
    await StorageService.saveTasks(_tasks);
    final updatedStats = _userStats.copyWith(
      totalXP: _userStats.totalXP + task.difficulty.xpReward,
      xp: _userStats.xp + task.difficulty.xpReward,
    );
    setState(() {
      _userStats = updatedStats;
    });
    await StorageService.saveUserStats(updatedStats);
  }

  // Aggiunge una nuova quest.
  Future<void> _addTask(Task task) async {
    _tasks.add(task);
    await StorageService.saveTasks(_tasks);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4C1D95), 
              Color(0xFF1E3A8A), 
              Color(0xFF312E81), 
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                StatsHeader(
                  userStats: _userStats,
                  onStatsPressed: () async {
                    final updatedStats = await Navigator.push<UserStats>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsScreen(
                          userStats: _userStats,
                        ),
                      ),
                    );
                    // Se sono state fatte modifiche, le salviamo e aggiorniamo la UI.
                    if (updatedStats != null) {
                      setState(() {
                        _userStats = updatedStats;
                      });
                      await StorageService.saveUserStats(updatedStats);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Quest del giorno
                Expanded(
                  child: Card(
                    color: Colors.black.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Today\'s Quests',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_completedToday/${_todayTasks.length}',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Expanded(
                            child: _todayTasks.isEmpty
                                // Se non ci sono quest, mostriamo un messaggio amichevole.
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 48,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No quests for today',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Create your first mission!',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                // Altrimenti, costruiamo la lista di quest.
                                : ListView.builder(
                                    itemCount: _todayTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = _todayTasks[index];
                                      return TaskCard(
                                        task: task,
                                        onComplete: () => _completeTask(task.id),
                                        onEdit: () async {
                                          // Passiamo la quest esistente al form per la modifica.
                                          final updatedTask = await Navigator.push<Task>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskFormScreen(task: task),
                                            ),
                                          );
                                          // Se il form restituisce una quest aggiornata, la salviamo.
                                          if (updatedTask != null) {
                                            final idx = _tasks.indexWhere((t) => t.id == task.id);
                                            if (idx != -1) {
                                              setState(() {
                                                _tasks[idx] = updatedTask;
                                              });
                                              await StorageService.saveTasks(_tasks);
                                            }
                                          }
                                        },
                                        onDelete: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete quest'),
                                              content: const Text('Are u sure ?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          // Se l'utente ha confermato, rimuoviamo la quest e salviamo.
                                          if (confirm == true) {
                                            setState(() {
                                              _tasks.removeWhere((t) => t.id == task.id);
                                            });
                                            await StorageService.saveTasks(_tasks);
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Azioni rapide
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final task = await Navigator.push<Task>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TaskFormScreen(),
                            ),
                          );
                          if (task != null) {
                            await _addTask(task);
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('New Quest'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final count = await StorageService.getRandomQuestCount();
                          if (count >= 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You can only generate 2 random quests per day. Create a custom one!')),
                            );
                            return;
                          }
                          final response = await http.get(Uri.parse('https://bored-api.appbrewery.com/random'));
                          if (response.statusCode == 200) {
                            final data = json.decode(response.body);
                            final title = data['activity'] ?? 'Random Quest';
                            final description = '';
                            final now = DateTime.now();
                            final quest = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              description: description,
                              category: 'Random Quest',
                              difficulty: TaskDifficulty.easy,
                              time: '',
                              date: DateTime(now.year, now.month, now.day),
                              completed: false,
                            );
                            await StorageService.saveTasks([..._tasks, quest]);
                            setState(() {
                              _tasks.add(quest);
                            });
                            await StorageService.incrementRandomQuestCount();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error while fetching the random quest.')),
                            );
                          }
                        },
                        child: const Text('Random Quest', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final tasks = await Navigator.push<List<Task>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PresetRoutinesScreen(),
                            ),
                          );
                          if (tasks != null) {
                            for (final task in tasks) {
                              await _addTask(task);
                            }
                          }
                        },
                        icon: const Icon(Icons.track_changes, color: Colors.white),
                        label: const Text('Routine'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Ripianifica le notifiche motivazionali.
  Future<void> _rescheduleNotifications() async {
    await NotificationService.cancelAll();
    await Future.delayed(const Duration(milliseconds: 500));
    await scheduleDailyMotivationalNotifications();
  }
}

class _NotificationTimesDialog extends StatefulWidget {
  final List<TimeOfDay> initialTimes;
  const _NotificationTimesDialog({required this.initialTimes});

  @override
  State<_NotificationTimesDialog> createState() => _NotificationTimesDialogState();
}

class _NotificationTimesDialogState extends State<_NotificationTimesDialog> {
  late List<TimeOfDay> _times;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.initialTimes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Imposta orari notifiche'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => ListTile(
          title: Text('Orario ${i + 1}: ${_times[i].format(context)}'),
          trailing: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _times[i],
              );
              if (picked != null) {
                setState(() => _times[i] = picked);
              }
            },
          ),
        )),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _times),
          child: const Text('Salva'),
        ),
      ],
    );
  }
}