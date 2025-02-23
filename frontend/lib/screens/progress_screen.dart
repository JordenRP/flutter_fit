import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _thighController = TextEditingController();
  final _notesController = TextEditingController();
  List<Map<String, dynamic>> progressEntries = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final response = await ApiService.get('/api/progress');
      setState(() {
        progressEntries = List<Map<String, dynamic>>.from(response ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных о прогрессе: ${e.toString()}')),
        );
      }
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

  Future<void> _submitProgress() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.post('/api/progress', {
          'date': _dateController.text,
          'weight': double.parse(_weightController.text),
          'chest': double.parse(_chestController.text),
          'waist': double.parse(_waistController.text),
          'hips': double.parse(_hipsController.text),
          'biceps': double.parse(_bicepsController.text),
          'thigh': double.parse(_thighController.text),
          'notes': _notesController.text,
        });
        _formKey.currentState!.reset();
        _loadProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Прогресс сохранен')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения прогресса')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Прогресс'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProgress,
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
                    controller: _weightController,
                    decoration: InputDecoration(labelText: 'Вес (кг)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите вес' : null,
                  ),
                  TextFormField(
                    controller: _chestController,
                    decoration: InputDecoration(labelText: 'Обхват груди (см)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите обхват груди' : null,
                  ),
                  TextFormField(
                    controller: _waistController,
                    decoration: InputDecoration(labelText: 'Обхват талии (см)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите обхват талии' : null,
                  ),
                  TextFormField(
                    controller: _hipsController,
                    decoration: InputDecoration(labelText: 'Обхват бедер (см)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите обхват бедер' : null,
                  ),
                  TextFormField(
                    controller: _bicepsController,
                    decoration: InputDecoration(labelText: 'Обхват бицепса (см)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите обхват бицепса' : null,
                  ),
                  TextFormField(
                    controller: _thighController,
                    decoration: InputDecoration(labelText: 'Обхват бедра (см)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Введите обхват бедра' : null,
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(labelText: 'Заметки'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitProgress,
                    child: Text('Сохранить измерения'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('История измерений', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: progressEntries.length,
              itemBuilder: (context, index) {
                final entry = progressEntries[index];
                return Card(
                  child: ListTile(
                    title: Text('Измерения от ${entry['date']?.toString().substring(0, 10) ?? ''}'),
                    subtitle: Text(
                      'Вес: ${entry['weight'] ?? 0} кг\n'
                      'Грудь: ${entry['chest'] ?? 0} см\n'
                      'Талия: ${entry['waist'] ?? 0} см\n'
                      'Бедра: ${entry['hips'] ?? 0} см\n'
                      'Бицепс: ${entry['biceps'] ?? 0} см\n'
                      'Бедро: ${entry['thigh'] ?? 0} см\n'
                      '${entry['notes'] ?? ''}'
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

  @override
  void dispose() {
    _dateController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _bicepsController.dispose();
    _thighController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 