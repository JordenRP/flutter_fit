import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _mealTypeController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  List<dynamic> nutritionEntries = [];

  @override
  void initState() {
    super.initState();
    _loadNutrition();
  }

  Future<void> _loadNutrition() async {
    try {
      final response = await ApiService.get('/api/nutrition');
      setState(() {
        nutritionEntries = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки записей о питании')),
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

  Future<void> _submitNutrition() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.post('/api/nutrition', {
          'date': _dateController.text,
          'meal_type': _mealTypeController.text,
          'food_name': _foodNameController.text,
          'calories': int.parse(_caloriesController.text),
          'proteins': double.parse(_proteinsController.text),
          'fats': double.parse(_fatsController.text),
          'carbs': double.parse(_carbsController.text),
        });
        _formKey.currentState!.reset();
        _loadNutrition();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Запись о питании добавлена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения записи о питании')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Питание')),
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
                    controller: _mealTypeController,
                    decoration: InputDecoration(labelText: 'Тип приема пищи'),
                    validator: (value) => value?.isEmpty ?? true ? 'Введите тип приема пищи' : null,
                  ),
                  TextFormField(
                    controller: _foodNameController,
                    decoration: InputDecoration(labelText: 'Название продукта'),
                    validator: (value) => value?.isEmpty ?? true ? 'Введите название продукта' : null,
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: InputDecoration(labelText: 'Калории'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите количество калорий' : null,
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    decoration: InputDecoration(labelText: 'Белки (г)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите количество белков' : null,
                  ),
                  TextFormField(
                    controller: _fatsController,
                    decoration: InputDecoration(labelText: 'Жиры (г)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите количество жиров' : null,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(labelText: 'Углеводы (г)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите количество углеводов' : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitNutrition,
                    child: Text('Добавить запись'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('История питания', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: nutritionEntries.length,
              itemBuilder: (context, index) {
                final entry = nutritionEntries[index];
                return Card(
                  child: ListTile(
                    title: Text('${entry['meal_type']} - ${entry['food_name']}'),
                    subtitle: Text(
                      '${entry['date'].substring(0, 10)}\nКалории: ${entry['calories']}, Б: ${entry['proteins']}г, Ж: ${entry['fats']}г, У: ${entry['carbs']}г',
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