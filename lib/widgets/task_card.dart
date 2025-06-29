import 'package:flutter/material.dart';
import '../models/task.dart';

// Card che mostra una quest.
class TaskCard extends StatelessWidget {
  final Task task;

  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  // Funzione di utilità per restituire un colore diverso in base alla difficoltà.
  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Colors.green;
      case TaskDifficulty.medium:
        return Colors.orange;
      case TaskDifficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onComplete != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onComplete,
                    tooltip: 'Complete',
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.yellow),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: task.completed ? Colors.green : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.completed 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                ),
                if (task.completed) const Text('✅'),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  color: task.completed 
                      ? Colors.green.withOpacity(0.6)
                      : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Il widget `Wrap` è utile per disporre i tag.
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getDifficultyColor(task.difficulty),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${task.difficulty.stars} ${task.difficulty.displayName}',
                    style: TextStyle(
                      color: _getDifficultyColor(task.difficulty),
                      fontSize: 12,
                    ),
                  ),
                ),
                if (task.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.category,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (task.time.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.purpleAccent),
                        const SizedBox(width: 4),
                        Text(
                          task.time,
                          style: const TextStyle(color: Colors.purpleAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${task.difficulty.xpReward} XP',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
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
}