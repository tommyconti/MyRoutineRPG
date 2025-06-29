import 'package:flutter/material.dart';
import '../models/task.dart';

// Schermata delle routine preimpostate.
class PresetRoutinesScreen extends StatelessWidget {
  const PresetRoutinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preset Routines'),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRoutineCard(
              context,
              'Warrior Morning Routine',
              'Start your day with energy',
              Icons.wb_sunny,
              Colors.orange,
              _getMorningTasks(),
            ),
            const SizedBox(height: 16),
            _buildRoutineCard(
              context,
              'Sage Evening Routine',
              'End your day in peace',
              Icons.nights_stay,
              Colors.indigo,
              _getEveningTasks(),
            ),
            const SizedBox(height: 16),
            _buildRoutineCard(
              context,
              'Warrior Workout',
              'Keep your body strong',
              Icons.fitness_center,
              Colors.red,
              _getWorkoutTasks(),
            ),
            const SizedBox(height: 16),
            _buildRoutineCard(
              context,
              'Wizard Study',
              'Expand your mind',
              Icons.school,
              Colors.purple,
              _getStudyTasks(),
            ),
          ],
        ),
      ),
    );
  }

  // Card per una routine preimpostata.
  Widget _buildRoutineCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<Task> tasks,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pop(context, tasks),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Included quests: ${tasks.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tasks.map((task) => Chip(
                  label: Text(
                    task.title,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Routine preimpostate.
List<Task> _getMorningTasks() {
  final today = DateTime.now();
  return [
    Task(
      id: '1',
      title: 'Warrior Meditation',
      description: '10 minutes of meditation',
      category: 'Wellness',
      difficulty: TaskDifficulty.easy,
      time: '07:00',
      date: today,
      completed: false,
    ),
    Task(
      id: '2',
      title: 'Energizing Breakfast',
      description: 'Prepare a healthy breakfast',
      category: 'Health',
      difficulty: TaskDifficulty.easy,
      time: '07:30',
      date: today,
      completed: false,
    ),
    Task(
      id: '3',
      title: 'Day Planning',
      description: 'Review your goals',
      category: 'Productivity',
      difficulty: TaskDifficulty.medium,
      time: '08:00',
      date: today,
      completed: false,
    ),
  ];
}

List<Task> _getEveningTasks() {
  final today = DateTime.now();
  return [
    Task(
      id: '4',
      title: 'Sage Reflection',
      description: 'Reflect on your day',
      category: 'Wellness',
      difficulty: TaskDifficulty.easy,
      time: '21:00',
      date: today,
      completed: false,
    ),
    Task(
      id: '5',
      title: 'Relaxing Reading',
      description: '30 minutes of reading',
      category: 'Culture',
      difficulty: TaskDifficulty.easy,
      time: '21:30',
      date: today,
      completed: false,
    ),
    Task(
      id: '6',
      title: 'Bedtime Preparation',
      description: 'Pre-sleep routine',
      category: 'Health',
      difficulty: TaskDifficulty.easy,
      time: '22:00',
      date: today,
      completed: false,
    ),
  ];
}

List<Task> _getWorkoutTasks() {
  final today = DateTime.now();
  return [
    Task(
      id: '7',
      title: 'Warm-up',
      description: '10 minutes of stretching',
      category: 'Fitness',
      difficulty: TaskDifficulty.easy,
      time: '18:00',
      date: today,
      completed: false,
    ),
    Task(
      id: '8',
      title: 'Strength Training',
      description: '30 minutes of exercises',
      category: 'Fitness',
      difficulty: TaskDifficulty.hard,
      time: '18:15',
      date: today,
      completed: false,
    ),
    Task(
      id: '9',
      title: 'Cool-down',
      description: '10 minutes of cool-down',
      category: 'Fitness',
      difficulty: TaskDifficulty.easy,
      time: '18:45',
      date: today,
      completed: false,
    ),
  ];
}

List<Task> _getStudyTasks() {
  final today = DateTime.now();
  return [
    Task(
      id: '10',
      title: 'Focused Study',
      description: '45 minutes of deep study',
      category: 'Learning',
      difficulty: TaskDifficulty.hard,
      time: '15:00',
      date: today,
      completed: false,
    ),
    Task(
      id: '11',
      title: 'Magic Review',
      description: 'Review what you learned',
      category: 'Learning',
      difficulty: TaskDifficulty.medium,
      time: '16:00',
      date: today,
      completed: false,
    ),
    Task(
      id: '12',
      title: 'Skill Practice',
      description: 'Apply acquired knowledge',
      category: 'Learning',
      difficulty: TaskDifficulty.medium,
      time: '16:30',
      date: today,
      completed: false,
    ),
  ];
}