import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class TrainingPlanScreen extends StatefulWidget {
  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<Map<String, dynamic>> trainingPlans = [];
  List<Map<String, dynamic>> exercises = [];
  int selectedDayOfWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadTrainingPlans();
  }

  Future<void> _loadTrainingPlans() async {
    try {
      final response = await ApiService.get('/api/training-plans');
      setState(() {
        trainingPlans = List<Map<String, dynamic>>.from(response ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки планов тренировок: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final setsController = TextEditingController();
        final repsController = TextEditingController();
        final weightController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: Text('Добавить упражнение'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Название упражнения'),
                ),
                TextFormField(
                  controller: setsController,
                  decoration: InputDecoration(labelText: 'Количество подходов'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: repsController,
                  decoration: InputDecoration(labelText: 'Количество повторений'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: weightController,
                  decoration: InputDecoration(labelText: 'Вес (кг)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  exercises.add({
                    'name': nameController.text,
                    'sets': int.tryParse(setsController.text) ?? 0,
                    'reps': int.tryParse(repsController.text) ?? 0,
                    'weight': double.tryParse(weightController.text) ?? 0.0,
                    'description': descriptionController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTrainingPlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        final days = [
          {
            'day_of_week': selectedDayOfWeek,
            'exercises': exercises,
          }
        ];

        await ApiService.post('/api/training-plans', {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
          'days': days,
        });

        _formKey.currentState!.reset();
        setState(() {
          exercises = [];
        });
        _loadTrainingPlans();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('План тренировок создан')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания плана тренировок')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Планы тренировок'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrainingPlans,
          ),
        ],
      ),
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
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Название плана'),
                    validator: (value) => value?.isEmpty ?? true ? 'Введите название плана' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Описание'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Дата начала',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_startDateController),
                      ),
                    ),
                    readOnly: true,
                    validator: (value) => value?.isEmpty ?? true ? 'Выберите дату начала' : null,
                  ),
                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Дата окончания',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_endDateController),
                      ),
                    ),
                    readOnly: true,
                    validator: (value) => value?.isEmpty ?? true ? 'Выберите дату окончания' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedDayOfWeek,
                    decoration: InputDecoration(labelText: 'День недели'),
                    items: [
                      DropdownMenuItem(value: 1, child: Text('Понедельник')),
                      DropdownMenuItem(value: 2, child: Text('Вторник')),
                      DropdownMenuItem(value: 3, child: Text('Среда')),
                      DropdownMenuItem(value: 4, child: Text('Четверг')),
                      DropdownMenuItem(value: 5, child: Text('Пятница')),
                      DropdownMenuItem(value: 6, child: Text('Суббота')),
                      DropdownMenuItem(value: 7, child: Text('Воскресенье')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDayOfWeek = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addExercise,
                    child: Text('Добавить упражнение'),
                  ),
                  if (exercises.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text('Упражнения:', style: Theme.of(context).textTheme.titleMedium),
                    ...exercises.map((exercise) => Card(
                      child: ListTile(
                        title: Text(exercise['name']),
                        subtitle: Text(
                          'Подходы: ${exercise['sets']}, '
                          'Повторения: ${exercise['reps']}, '
                          'Вес: ${exercise['weight']} кг\n'
                          '${exercise['description']}'
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              exercises.remove(exercise);
                            });
                          },
                        ),
                      ),
                    )).toList(),
                  ],
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitTrainingPlan,
                    child: Text('Создать план'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Мои планы тренировок', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: trainingPlans.length,
              itemBuilder: (context, index) {
                final plan = trainingPlans[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(plan['name']),
                    subtitle: Text(
                      'С ${plan['start_date'].toString().substring(0, 10)} '
                      'по ${plan['end_date'].toString().substring(0, 10)}'
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan['description'] ?? ''),
                            SizedBox(height: 8),
                            ...(plan['days'] as List).map((day) {
                              final exercises = day['exercises'] as List;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'День ${day['day_of_week']}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  ...exercises.map((exercise) => ListTile(
                                    title: Text(exercise['name']),
                                    subtitle: Text(
                                      'Подходы: ${exercise['sets']}, '
                                      'Повторения: ${exercise['reps']}, '
                                      'Вес: ${exercise['weight']} кг\n'
                                      '${exercise['description']}'
                                    ),
                                  )).toList(),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
} 