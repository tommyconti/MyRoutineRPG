enum TaskDifficulty { easy, medium, hard }

// Rappresenta una quest o attività da completare.
// Come `UserStats`, questa classe è immutabile.
class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskDifficulty difficulty;
  final String time;
  final DateTime date;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.time,
    required this.date,
    required this.completed,
  });

  // Converte Task in una mappa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty.name,
      'time': time,
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }

  // Crea Task da una mappa JSON.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      // Ricostruiamo l'enum dal suo nome. `orElse` gestisce casi in cui il valore salvato non sia valido, prevenendo crash.
      difficulty: TaskDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => TaskDifficulty.easy,
      ),
      time: json['time'],
      date: DateTime.parse(json['date']),
      completed: json['completed'] ?? false,
    );
  }

  // Crea una copia della quest con eventuali modifiche.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskDifficulty? difficulty,
    String? time,
    DateTime? date,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      time: time ?? this.time,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }
}

// Extension per funzionalità aggiuntive su TaskDifficulty.
extension TaskDifficultyExtension on TaskDifficulty {
  String get displayName {
    switch (this) {
      case TaskDifficulty.easy:
        return 'Easy';
      case TaskDifficulty.medium:
        return 'Medium';
      case TaskDifficulty.hard:
        return 'Hard';
    }
  }

  // Restituisce una rappresentazione a "stelle" per la difficoltà.
  String get stars {
    switch (this) {
      case TaskDifficulty.easy:
        return '⭐';
      case TaskDifficulty.medium:
        return '⭐⭐';
      case TaskDifficulty.hard:
        return '⭐⭐⭐';
    }
  }

  // La quantità di XP che una quest conferisce in base alla sua difficoltà.
  int get xpReward {
    switch (this) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 20;
      case TaskDifficulty.hard:
        return 30;
    }
  }
}