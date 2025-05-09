import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/task_item.dart';
import 'task_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedCategory;
  final TextEditingController _newCategoryController = TextEditingController();
  Color _selectedColor = AppTheme.categoryColors.first;

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(
                        begin: -0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'Organize your tasks by category',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(
                        begin: -0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOutQuad,
                        delay: 100.ms,
                      ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category List
                    _buildCategoryList(),

                    // Add New Category Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddCategoryDialog(),
                        icon: const Icon(Iconsax.add),
                        label: const Text('Add New Category'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    // Tasks by Selected Category
                    if (_selectedCategory != null) _buildTasksByCategory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Consumer2<CategoryProvider, TaskProvider>(
      builder: (context, categoryProvider, taskProvider, _) {
        final categories = categoryProvider.categories;

        if (categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Iconsax.category,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No categories yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first category to organize tasks',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate responsive grid based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount;
        double childAspectRatio;

        // Responsive breakpoints
        if (screenWidth < 360) {
          // Very small devices
          crossAxisCount = 1;
          childAspectRatio = 2.5;
        } else if (screenWidth < 600) {
          // Phone
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else if (screenWidth < 900) {
          // Tablet in portrait
          crossAxisCount = 3;
          childAspectRatio = 1.6;
        } else {
          // Tablet landscape or larger
          crossAxisCount = 4;
          childAspectRatio = 1.7;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryName = category.name;
            final categoryColor = category.color;
            final taskCount =
                taskProvider.getTasksByCategory(categoryName).length;
            final isSelected = _selectedCategory == categoryName;

            // Check if it's a predefined category
            final isPredefined = AppTheme.predefinedCategories
                .any((c) => c['name'] == categoryName);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? null : categoryName;
                });
              },
              onLongPress: () {
                // Don't allow editing predefined categories
                if (!isPredefined) {
                  _showCategoryActions(category);
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate font size based on available space
                  final cardWidth = constraints.maxWidth;
                  final titleFontSize = cardWidth < 160 ? 14.0 : 16.0;
                  final countFontSize = cardWidth < 160 ? 12.0 : 14.0;

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? categoryColor.withOpacity(0.2)
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? categoryColor
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(cardWidth < 160 ? 12 : 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleFontSize,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$taskCount task${taskCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: countFontSize,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit & Delete options for non-predefined categories
                      if (!isPredefined)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _showCategoryActions(category),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.more,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                      begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
                  .elevation(begin: 0, end: 8),
            );
          },
        );
      },
    );
  }

  Widget _buildTasksByCategory() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final allTasks = taskProvider.getTasksByCategory(_selectedCategory!);

        if (allTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Iconsax.category,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks in $_selectedCategory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black54
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new task to this category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter options
        final completedTasks =
            allTasks.where((task) => task.isCompleted).toList();
        final pendingTasks =
            allTasks.where((task) => !task.isCompleted).toList();
        final todayTasks = allTasks
            .where((task) => AppDateUtils.isToday(task.dueDate))
            .toList();
        final tomorrowTasks = allTasks
            .where((task) => AppDateUtils.isTomorrow(task.dueDate))
            .toList();
        final overdueTasks = allTasks
            .where((task) =>
                !task.isCompleted && AppDateUtils.isOverdue(task.dueDate))
            .toList();

        // Sort by due date
        allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks in $_selectedCategory',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pendingTasks.length}/${allTasks.length} pending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 50,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All (${allTasks.length})',
                      () => _showFilteredTasks('All', allTasks)),
                  _buildFilterChip('Pending (${pendingTasks.length})',
                      () => _showFilteredTasks('Pending', pendingTasks)),
                  _buildFilterChip('Completed (${completedTasks.length})',
                      () => _showFilteredTasks('Completed', completedTasks)),
                  _buildFilterChip('Today (${todayTasks.length})',
                      () => _showFilteredTasks('Today', todayTasks)),
                  _buildFilterChip('Tomorrow (${tomorrowTasks.length})',
                      () => _showFilteredTasks('Tomorrow', tomorrowTasks)),
                  if (overdueTasks.isNotEmpty)
                    _buildFilterChip(
                        'Overdue (${overdueTasks.length})',
                        () => _showFilteredTasks('Overdue', overdueTasks),
                        Colors.redAccent),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Task list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                return TaskItemWidget(
                  task: allTasks[index],
                  onTap: () => _navigateToTaskDetail(allTasks[index]),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, Function() onTap, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor:
              color ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _showFilteredTasks(String filterName, List<Task> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$filterName Tasks in $_selectedCategory',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.tick_circle,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $filterName tasks',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskItemWidget(
                        task: tasks[index],
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToTaskDetail(tasks[index]);
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            const Text('Select Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppTheme.categoryColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Iconsax.tick_circle,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newCategoryController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryName = _newCategoryController.text.trim();
              if (categoryName.isNotEmpty) {
                final categoryProvider =
                    Provider.of<CategoryProvider>(context, listen: false);
                categoryProvider.addCategory(categoryName, _selectedColor);

                setState(() {
                  _selectedCategory = categoryName;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Category "$categoryName" added successfully'),
                    backgroundColor: _selectedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              Navigator.of(context).pop();
              _newCategoryController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _showCategoryActions(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*ListTile(
            leading: const Icon(Iconsax.edit),
            title: const Text('Edit Category'),
            onTap: () {
              Navigator.pop(context);
              _showEditCategoryDialog(category);
            },
          ),*/
          ListTile(
            leading: const Icon(Iconsax.trash),
            title: const Text('Delete Category'),
            onTap: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    _newCategoryController.text = category.name;
    _selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            const Text('Select Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppTheme.categoryColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Iconsax.tick_circle,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newCategoryController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryName = _newCategoryController.text.trim();
              if (categoryName.isNotEmpty) {
                final categoryProvider =
                    Provider.of<CategoryProvider>(context, listen: false);
                categoryProvider.updateCategory(
                    category.id, categoryName, _selectedColor);

                setState(() {
                  _selectedCategory = categoryName;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Category "$categoryName" updated successfully'),
                    backgroundColor: _selectedColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              Navigator.of(context).pop();
              _newCategoryController.clear();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Are you sure you want to delete "${category.name}"?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final categoryProvider =
                          Provider.of<CategoryProvider>(context, listen: false);
                      categoryProvider.deleteCategory(category.id);

                      setState(() {
                        if (_selectedCategory == category.name) {
                          _selectedCategory = null;
                        }
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Category "${category.name}" deleted successfully'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Delete'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
