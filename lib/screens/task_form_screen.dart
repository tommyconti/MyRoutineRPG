import 'package:flutter/material.dart';
import '../models/task.dart';

// Schermata per creare o modificare una quest.
class TaskFormScreen extends StatefulWidget {
  // Se `task` è nullo, siamo in modalità "creazione".
  // Altrimenti, siamo in modalità "modifica" e questo è il task da modificare.
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // I controller ci permettono di gestire il testo nei campi di input.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  TimeOfDay? _selectedTime;
  
  TaskDifficulty _difficulty = TaskDifficulty.easy;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _categoryController.text = widget.task!.category;
      if (widget.task!.time.isNotEmpty) {
        final timeParts = widget.task!.time.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      }
      _difficulty = widget.task!.difficulty;
      _selectedDate = widget.task!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Il titolo della pagina cambia a seconda se stiamo creando o modificando.
        title: Text(widget.task == null ? 'Quest Title' : 'Edit Quest'),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildTextField(_titleController, 'Quest Title', Icons.flag, maxLength: 30),
                        const SizedBox(height: 16),
                        _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3, maxLength: 100),
                        const SizedBox(height: 16),
                        _buildTextField(_categoryController, 'Category', Icons.category, maxLength: 20),
                        const SizedBox(height: 16),
                        _buildTimeSelector(),
                        const SizedBox(height: 16),
                        _buildDifficultySelector(),
                        const SizedBox(height: 16),
                        _buildDateSelector(),
                        const SizedBox(height: 24),
                        const Spacer(),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Campo di testo personalizzato.
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // Selettore orario.
  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              _selectedTime == null ? 'Select time' : _selectedTime!.format(context),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Selettore difficoltà.
  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.white),
              SizedBox(width: 8),
              Text('Difficulty', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDifficultyChip('easy', 'Easy', Colors.green),
              const SizedBox(width: 8),
              _buildDifficultyChip('medium', 'Medium', Colors.orange),
              const SizedBox(width: 8),
              _buildDifficultyChip('hard', 'Hard', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // Chip per la difficoltà.
  Widget _buildDifficultyChip(String value, String label, Color color) {
    final difficultyValue = TaskDifficulty.values.firstWhere((e) => e.name == value);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = difficultyValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _difficulty == difficultyValue ? color : Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _difficulty == difficultyValue ? color : Colors.white30,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _difficulty == difficultyValue ? Colors.white : Colors.white70,
              fontWeight: _difficulty == difficultyValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Selettore data.
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Pulsante per salvare la quest.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white30),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          widget.task == null ? 'Create Quest' : 'Save',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Salva la quest (crea o aggiorna).
  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insert a title')),
      );
      return;
    }

    final task = Task(
      // Se stiamo modificando, usiamo l'ID esistente. Altrimenti, ne creiamo uno nuovo.
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      difficulty: _difficulty,
      time: _selectedTime == null ? '' : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      date: _selectedDate,
      completed: widget.task?.completed ?? false,
    );

    // `Navigator.pop` chiude la schermata attuale e "restituisce" l'oggetto `task` alla schermata `HomeScreen`
    Navigator.pop(context, task);
  }
}