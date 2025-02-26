import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/category.dart';
import 'auth_service.dart';

class TaskService {
  static const baseUrl = 'http://localhost:8080/api/tasks';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Task>> getTasks({Category? category}) async {
    final url = category != null 
        ? 'http://localhost:8080/api/categories/${category.id}/tasks'
        : baseUrl;
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(String title, String description, DateTime dueDate, int priority, {Category? category}) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'category_id': category?.id,
      }),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(int id, String title, String description, bool completed, DateTime dueDate, int priority, {Category? category}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'completed': completed,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'category_id': category?.id,
      }),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
} 