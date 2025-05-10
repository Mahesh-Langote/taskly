import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  Color color; // For note color styling
  String taskId; // Foreign key to link with task
  String?
      category; // Category for the note (e.g., "Ideas", "Blockers", "Resources")
  List<String> tags; // Tags for better organization
  List<String> attachments; // URLs or paths to attachments
  bool isPinned; // Whether the note is pinned (shown at the top)
  String? location; // Optional location information

  Note({
    String? id,
    required this.title,
    this.content = '',
    required this.taskId,
    this.color = Colors.white,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category,
    List<String>? tags,
    List<String>? attachments,
    this.isPinned = false,
    this.location,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        attachments = attachments ?? [];

  // Convert Note to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'taskId': taskId,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
      'tags': tags,
      'attachments': attachments,
      'isPinned': isPinned,
      'location': location,
    };
  }

  // Create Note from Map
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      taskId: json['taskId'],
      color: Color(json['color']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      isPinned: json['isPinned'] ?? false,
      location: json['location'],
    );
  }

  // Create a copy of the note with potential modifications
  Note copyWith({
    String? title,
    String? content,
    Color? color,
    DateTime? updatedAt,
    String? category,
    List<String>? tags,
    List<String>? attachments,
    bool? isPinned,
    String? location,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      taskId: taskId,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      category: category ?? this.category,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      isPinned: isPinned ?? this.isPinned,
      location: location ?? this.location,
    );
  }
}
