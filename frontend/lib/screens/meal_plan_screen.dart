import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MealPlanScreen extends StatefulWidget {
  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<Map<String, dynamic>> mealPlans = [];
  List<Map<String, dynamic>> meals = [];
  int selectedDayOfWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    try {
      final response = await ApiService.get('/api/meal-plans');
      setState(() {
        mealPlans = List<Map<String, dynamic>>.from(response ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки планов питания: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addMeal() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final caloriesController = TextEditingController();
        final proteinsController = TextEditingController();
        final carbsController = TextEditingController();
        final fatsController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: Text('Добавить прием пищи'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Название блюда'),
                ),
                TextFormField(
                  controller: caloriesController,
                  decoration: InputDecoration(labelText: 'Калории'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: proteinsController,
                  decoration: InputDecoration(labelText: 'Белки (г)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: carbsController,
                  decoration: InputDecoration(labelText: 'Углеводы (г)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: fatsController,
                  decoration: InputDecoration(labelText: 'Жиры (г)'),
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
                  meals.add({
                    'name': nameController.text,
                    'calories': int.tryParse(caloriesController.text) ?? 0,
                    'proteins': double.tryParse(proteinsController.text) ?? 0.0,
                    'carbs': double.tryParse(carbsController.text) ?? 0.0,
                    'fats': double.tryParse(fatsController.text) ?? 0.0,
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

  Future<void> _submitMealPlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        final days = [
          {
            'day_of_week': selectedDayOfWeek,
            'meals': meals,
          }
        ];

        await ApiService.post('/api/meal-plans', {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
          'days': days,
        });

        _formKey.currentState!.reset();
        setState(() {
          meals = [];
        });
        _loadMealPlans();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('План питания создан')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания плана питания')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Планы питания'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMealPlans,
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
                    onPressed: _addMeal,
                    child: Text('Добавить прием пищи'),
                  ),
                  if (meals.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text('Приемы пищи:', style: Theme.of(context).textTheme.titleMedium),
                    ...meals.map((meal) => Card(
                      child: ListTile(
                        title: Text(meal['name']),
                        subtitle: Text(
                          'Калории: ${meal['calories']}\n'
                          'Белки: ${meal['proteins']}г, '
                          'Углеводы: ${meal['carbs']}г, '
                          'Жиры: ${meal['fats']}г\n'
                          '${meal['description']}'
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              meals.remove(meal);
                            });
                          },
                        ),
                      ),
                    )).toList(),
                  ],
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitMealPlan,
                    child: Text('Создать план'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Мои планы питания', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: mealPlans.length,
              itemBuilder: (context, index) {
                final plan = mealPlans[index];
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
                              final meals = day['meals'] as List;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'День ${day['day_of_week']}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  ...meals.map((meal) => ListTile(
                                    title: Text(meal['name']),
                                    subtitle: Text(
                                      'Калории: ${meal['calories']}\n'
                                      'Белки: ${meal['proteins']}г, '
                                      'Углеводы: ${meal['carbs']}г, '
                                      'Жиры: ${meal['fats']}г\n'
                                      '${meal['description']}'
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