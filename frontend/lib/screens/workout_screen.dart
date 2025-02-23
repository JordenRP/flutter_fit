import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<dynamic> workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final response = await ApiService.get('/api/workouts');
      setState(() {
        workouts = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки тренировок')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitWorkout() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.post('/api/workouts', {
          'date': _dateController.text,
          'type': _typeController.text,
          'duration': int.parse(_durationController.text),
          'description': _descriptionController.text,
        });
        _formKey.currentState!.reset();
        _loadWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Тренировка добавлена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения тренировки')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тренировки')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Дата',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                    readOnly: true,
                    validator: (value) => value?.isEmpty ?? true ? 'Выберите дату' : null,
                  ),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(labelText: 'Тип тренировки'),
                    validator: (value) => value?.isEmpty ?? true ? 'Введите тип тренировки' : null,
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(labelText: 'Длительность (минуты)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите длительность' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Описание'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitWorkout,
                    child: Text('Добавить тренировку'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('История тренировок', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Card(
                  child: ListTile(
                    title: Text(workout['type']),
                    subtitle: Text(
                      '${workout['date'].substring(0, 10)} - ${workout['duration']} мин\n${workout['description']}',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}