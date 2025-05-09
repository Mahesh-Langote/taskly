import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  Color categoryColor;
  String category;
  int priority; // 1 - Low, 2 - Medium, 3 - High
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    required this.categoryColor,
    required this.category,
    this.priority = 2,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Task to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'categoryColor': categoryColor.value,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Task from Map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      categoryColor: Color(json['categoryColor']),
      category: json['category'],
      priority: json['priority'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Create a copy of the task with potential modifications
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    Color? categoryColor,
    String? category,
    int? priority,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryColor: categoryColor ?? this.categoryColor,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ??
          DateTime
              .now(), // Always update the timestamp when modifications are made
    );
  }
}
