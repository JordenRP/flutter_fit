import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/progress_chart.dart';

class ProgressStatsScreen extends StatefulWidget {
  @override
  _ProgressStatsScreenState createState() => _ProgressStatsScreenState();
}

class _ProgressStatsScreenState extends State<ProgressStatsScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = false;
  String selectedMeasurement = 'weight';

  final Map<String, String> measurementLabels = {
    'weight': 'Вес',
    'chest': 'Грудь',
    'waist': 'Талия',
    'hips': 'Бедра',
    'biceps': 'Бицепс',
    'thigh': 'Бедро',
  };

  final Map<String, Color> measurementColors = {
    'weight': Colors.blue,
    'chest': Colors.green,
    'waist': Colors.red,
    'hips': Colors.purple,
    'biceps': Colors.orange,
    'thigh': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDateController.text = DateFormat('yyyy-MM-dd').format(now);
    _startDateController.text = DateFormat('yyyy-MM-dd').format(
      now.subtract(const Duration(days: 30)),
    );
    _loadData();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final statsResponse = await ApiService.post('/api/progress/stats', {
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
      });

      final chartResponse = await ApiService.post('/api/progress/chart', {
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
      });

      setState(() {
        stats = statsResponse;
        chartData = List<Map<String, dynamic>>.from(chartResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    }
  }

  Widget _buildStatsCard() {
    if (stats == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Изменения за период',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (var entry in measurementLabels.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.value),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Начало: ${stats!['start_${entry.key}'].toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Сейчас: ${stats!['current_${entry.key}'].toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Изменение: ${stats!['${entry.key}_change'].toStringAsFixed(1)}',
                          style: TextStyle(
                            color: stats!['${entry.key}_change'] > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика прогресса'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Начальная дата',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_startDateController),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Конечная дата',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(_endDateController),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildStatsCard(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'График прогресса',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMeasurement,
                        decoration: const InputDecoration(
                          labelText: 'Показатель',
                          border: OutlineInputBorder(),
                        ),
                        items: measurementLabels.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMeasurement = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (chartData.isNotEmpty)
                        ProgressChart(
                          data: chartData,
                          measurementType: selectedMeasurement,
                          lineColor: measurementColors[selectedMeasurement]!,
                        )
                      else
                        const Center(
                          child: Text('Нет данных для отображения графика'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
} 