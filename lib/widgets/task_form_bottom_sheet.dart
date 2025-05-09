import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class TaskFormBottomSheet extends StatefulWidget {
  final Task? task;

  const TaskFormBottomSheet({super.key, this.task});

  @override
  State<TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends State<TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _markdownPreviewKey = GlobalKey();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Work';
  Color _selectedColor = AppTheme.predefinedCategories.first['color'] as Color;
  int _selectedPriority = 2; // Default: Medium priority
  bool _showMarkdownPreview = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // If we're editing an existing task, populate the form fields
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      _selectedCategory = widget.task!.category;
      _selectedColor = widget.task!.categoryColor;
      _selectedPriority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Combine date and time into a single DateTime object
      final dueDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (_isEditing) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text,
          dueDate: dueDateTime,
          categoryColor: _selectedColor,
          category: _selectedCategory,
          priority: _selectedPriority,
        );

        taskProvider.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text,
          dueDate: dueDateTime,
          categoryColor: _selectedColor,
          category: _selectedCategory,
          priority: _selectedPriority,
        );

        taskProvider.addTask(newTask);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _showCategoryPicker() {
    final categoryProvider =
    Provider.of<CategoryProvider>(context, listen: false);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categoryProvider.categories.map((category) {
                final name = category.name;
                final color = category.color;
                final isSelected = _selectedCategory == name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = name;
                      _selectedColor = color;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.surface : color,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Iconsax.check, color: Colors.white)
                            : Icon(
                          _getCategoryIcon(name),
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMarkdownPreview() {
    setState(() {
      _showMarkdownPreview = !_showMarkdownPreview;
    });
  }

  void _showMarkdownHelp() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Markdown Guide', style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.colorScheme.surface,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _markdownHelpItem('# Heading 1', 'Heading 1'),
              _markdownHelpItem('## Heading 2', 'Heading 2'),
              _markdownHelpItem('**Bold text**', 'Bold text'),
              _markdownHelpItem('*Italic text*', 'Italic text'),
              _markdownHelpItem('- Bullet point', 'List item'),
              _markdownHelpItem('1. Numbered item', 'Numbered list'),
              _markdownHelpItem('[Link text](URL)', 'Link'),
              _markdownHelpItem('`Code`', 'Inline code'),
              _markdownHelpItem('> Quote', 'Blockquote'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _markdownHelpItem(String syntax, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(syntax, style: TextStyle(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            )),
          ),
          Expanded(
            flex: 1,
            child: Text(description, style: TextStyle(color: theme.colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Iconsax.briefcase;         // Work-related
      case 'Personal':
        return Iconsax.profile_circle;    // Personal identity
      case 'Health':
        return Iconsax.heart;             // Health and wellness
      case 'Learning':
        return Iconsax.book;              // Education, learning
      case 'Shopping':
        return Iconsax.shopping_cart;     // Shopping cart
      case 'Finance':
        return Iconsax.wallet;            // Money, budget, finance
      case 'Home':
        return Iconsax.home;              // Home category
      default:
        return Iconsax.category_2;        // General category fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? theme.colorScheme.surface
        : Colors.white;

    final textColor = isDarkMode
        ? theme.colorScheme.onSurface
        : Colors.black;

    final inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
      labelStyle: TextStyle(color: theme.colorScheme.primary),
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      prefixIconColor: theme.colorScheme.primary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header and drag handle
                Column(
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isEditing ? 'Edit Task' : 'New Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(
                          begin: -0.2,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutQuad,
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Iconsax.close_circle, color: textColor),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title Field
                Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: inputDecorationTheme,
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'Enter task title',
                      prefixIcon: Icon(Iconsax.text_italic, color: theme.colorScheme.primary),
                    ),
                    style: TextStyle(color: textColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 100.ms,
                ),
                const SizedBox(height: 16),

                // Description Field with Markdown support
                _showMarkdownPreview
                    ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Iconsax.edit,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                onPressed: _toggleMarkdownPreview,
                                tooltip: 'Edit',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Iconsax.message_question,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                onPressed: _showMarkdownHelp,
                                tooltip: 'Markdown Help',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _descriptionController.text.isNotEmpty
                            ? Markdown(
                          key: _markdownPreviewKey,
                          data: _descriptionController.text,
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: TextStyle(color: textColor),
                            h1: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            h2: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            h3: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
                            strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            code: TextStyle(
                              color: theme.colorScheme.primary,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              fontFamily: 'monospace',
                            ),
                            blockquote: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        )
                            : Center(
                          child: Text(
                            'No description',
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: inputDecorationTheme,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter task description (supports markdown)',
                          prefixIcon: Icon(Iconsax.book_1, color: theme.colorScheme.primary),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Iconsax.eye,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _toggleMarkdownPreview,
                                tooltip: 'Preview Markdown',
                              ),
                              IconButton(
                                icon: Icon(
                                  Iconsax.message_question,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _showMarkdownHelp,
                                tooltip: 'Markdown Help',
                              ),
                            ],
                          ),
                        ),
                        style: TextStyle(color: textColor),
                        maxLines: 7,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports Markdown',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 200.ms,
                ),
                const SizedBox(height: 20),

                // Date and Time Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.calendar, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(fontSize: 16, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.timer, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 16, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 300.ms,
                ),
                const SizedBox(height: 20),

                // Category Selector
                InkWell(
                  onTap: _showCategoryPicker,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(_selectedCategory),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedCategory,
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        const Spacer(),
                        Icon(Iconsax.arrow_down, color: textColor.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 400.ms,
                ),
                const SizedBox(height: 20),

                // Priority Slider
                Text(
                  'Priority: ${_getPriorityText(_selectedPriority)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getPriorityColor(_selectedPriority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _selectedPriority.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  activeColor: _getPriorityColor(_selectedPriority),
                  inactiveColor:
                  _getPriorityColor(_selectedPriority).withOpacity(0.3),
                  label: _getPriorityText(_selectedPriority),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value.round();
                    });
                  },
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 500.ms,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      _isEditing ? 'Update Task' : 'Add Task',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                  delay: 600.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Medium';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}