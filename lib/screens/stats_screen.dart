import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../../main.dart' show scheduleDailyMotivationalNotifications;

// Schermata delle statistiche utente.
class StatsScreen extends StatefulWidget {
  final UserStats userStats;
  const StatsScreen({Key? key, required this.userStats}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

// `StatefulWidget` perché lo stato dell'utente può essere modificato direttamente da questa schermata.
class _StatsScreenState extends State<StatsScreen> {
  // Una copia locale delle statistiche per permettere la modifica in tempo reale.
  late UserStats _userStats;
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inizializziamo la nostra copia locale con i dati passati dalla HomeScreen.
    _userStats = widget.userStats;
    _nicknameController.text = _userStats.nickname;
  }

  // Mostra un dialog per modificare il nickname.
  Future<void> _editNickname() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(hintText: 'Your new nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Quando l'utente salva, aggiorniamo la nostra copia locale delle statistiche e chiudiamo il pop-up.
              setState(() {
                _userStats = _userStats.copyWith(nickname: _nicknameController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope intercetta il tentativo dell'utente di tornare indietro per permetterci di eseguire un'azione.
    return WillPopScope(
      onWillPop: () async {
        // Prima di chiudere la pagina, restituiamo le statistiche aggiornate alla HomeScreen, che si occuperà di salvarle.
        Navigator.pop(context, _userStats);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Expanded(
                child: Text('Stats'),
              ),
              IconButton(
                icon: const Icon(Icons.schedule, color: Colors.white),
                tooltip: 'Set notification time',
                onPressed: () async {
                  final times = await StorageService.getNotificationTimes();
                  final newTimes = await showDialog<List<TimeOfDay>>(
                    context: context,
                    builder: (context) => _NotificationTimesDialog(initialTimes: times),
                  );
                  if (newTimes != null && newTimes.length == 3) {
                    await StorageService.saveNotificationTimes(newTimes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification time updated!')),
                    );
                    await scheduleDailyMotivationalNotifications();
                  }
                },
              ),
            ],
          ),
          backgroundColor: Colors.purple[800],
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple[900]!, Colors.indigo[900]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildStatsCard(),
                const SizedBox(height: 24),
                _buildAchievementsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card con le statistiche utente.
  Widget _buildStatsCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70),
                  onPressed: _editNickname,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Nickname', _userStats.nickname, Colors.white),
            _buildStatRow('Title', _userStats.title, Colors.white),
            _buildStatRow('Level', _userStats.level.toString(), Colors.white),
            _buildStatRow('Total XP', _userStats.totalXP.toString(), Colors.white),
          ],
        ),
      ),
    );
  }

  // Card con i traguardi utente.
  Widget _buildAchievementsCard() {
    // La mappa definisce i titoli da sbloccare e il livello richiesto.
    final achievements = {
      'assassin': 5,
      'night lord': 10,
      'necromancer': 15,
      'the monarch of shadows': 20,
    };

    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Achievements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAchievement('First Step', 'Complete your first quest', _userStats.totalXP > 0),
            // Usiamo .map() per trasformare ogni elemento della mappa `achievements` in un widget `_buildAchievement`.
            ...achievements.entries.map((entry) {
              final title = entry.key.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
              final level = entry.value;
              return _buildAchievement(title, 'Reach level $level', _userStats.level >= level);
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Riga per una statistica.
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Mostra un traguardo.
  Widget _buildAchievement(String title, String description, bool achieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            color: achieved ? Colors.green : Colors.white30,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: achieved ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: achieved ? Colors.white70 : Colors.white30,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      title: const Text('Set notification time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => ListTile(
          title: Text('Time ${i + 1}: ${_times[i].format(context)}'),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _times),
          child: const Text('Save'),
        ),
      ],
    );
  }
}