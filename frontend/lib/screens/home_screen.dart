import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? latestProgress;
  Map<String, dynamic>? latestTrainingPlan;
  Map<String, dynamic>? latestMealPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final progressResponse = await ApiService.get('/api/progress');
      final trainingResponse = await ApiService.get('/api/training-plans');
      final mealResponse = await ApiService.get('/api/meal-plans');

      setState(() {
        if (progressResponse != null && (progressResponse as List).isNotEmpty) {
          latestProgress = progressResponse.last;
        }
        if (trainingResponse != null && (trainingResponse as List).isNotEmpty) {
          latestTrainingPlan = trainingResponse.last;
        }
        if (mealResponse != null && (mealResponse as List).isNotEmpty) {
          latestMealPlan = mealResponse.last;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Последние измерения',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            if (latestProgress != null) ...[
              Text('Вес: ${latestProgress!['weight']} кг'),
              Text('Дата: ${latestProgress!['date'].toString().substring(0, 10)}'),
              if (latestProgress!['measurements'] != null) ...[
                Text('Обхват груди: ${latestProgress!['measurements']['chest']} см'),
                Text('Обхват талии: ${latestProgress!['measurements']['waist']} см'),
                Text('Обхват бедер: ${latestProgress!['measurements']['hips']} см'),
              ],
            ] else
              Text('Нет данных о прогрессе'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingPlanCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Текущий план тренировок',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            if (latestTrainingPlan != null) ...[
              Text(latestTrainingPlan!['name']),
              Text('С ${latestTrainingPlan!['start_date'].toString().substring(0, 10)}'),
              Text('по ${latestTrainingPlan!['end_date'].toString().substring(0, 10)}'),
              if (latestTrainingPlan!['days'] != null &&
                  (latestTrainingPlan!['days'] as List).isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Ближайшая тренировка:'),
                Text('День ${(latestTrainingPlan!['days'] as List).first['day_of_week']}'),
                ...(((latestTrainingPlan!['days'] as List).first['exercises'] as List)
                    .take(3)
                    .map((e) => Text('• ${e['name']}')))
              ],
            ] else
              Text('Нет активного плана тренировок'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Текущий план питания',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            if (latestMealPlan != null) ...[
              Text(latestMealPlan!['name']),
              Text('С ${latestMealPlan!['start_date'].toString().substring(0, 10)}'),
              Text('по ${latestMealPlan!['end_date'].toString().substring(0, 10)}'),
              if (latestMealPlan!['days'] != null &&
                  (latestMealPlan!['days'] as List).isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Сегодняшнее меню:'),
                Text('День ${(latestMealPlan!['days'] as List).first['day_of_week']}'),
                ...(((latestMealPlan!['days'] as List).first['meals'] as List)
                    .take(3)
                    .map((m) => Text('• ${m['name']} (${m['calories']} ккал)')))
              ],
            ] else
              Text('Нет активного плана питания'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фитнес Трекер'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressCard(),
              SizedBox(height: 16),
              _buildTrainingPlanCard(),
              SizedBox(height: 16),
              _buildMealPlanCard(),
            ],
          ),
        ),
      ),
    );
  }
} 