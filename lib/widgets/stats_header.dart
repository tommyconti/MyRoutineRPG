import 'package:flutter/material.dart';
import '../models/user_stats.dart';

// Header che mostra le statistiche utente nella home.
class StatsHeader extends StatelessWidget {
  final UserStats userStats;
  final VoidCallback onStatsPressed;

  const StatsHeader({
    super.key,
    required this.userStats,
    required this.onStatsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userStats.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userStats.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Pulsante che mostra il livello e porta alla schermata delle statistiche.
                OutlinedButton.icon(
                  onPressed: onStatsPressed,
                  icon: const Icon(Icons.person),
                  label: Text('Lv.${userStats.level}'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sezione per la barra di progresso dell'XP.
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'XP Progress',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${userStats.xp}/100',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: userStats.xp / 100,
                  backgroundColor: Colors.purple.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}