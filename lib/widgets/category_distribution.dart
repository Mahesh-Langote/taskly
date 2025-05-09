import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import 'empty_chart_placeholder.dart';

class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.tasks;
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;

        if (tasks.isEmpty) {
          return const EmptyChartPlaceholder(
              title: 'Category Distribution',
              message: 'No tasks available to analyze');
        }

        // Group tasks by category
        final Map<String, int> categoryCount = {};
        for (var task in tasks) {
          final category =
              task.category.trim().isNotEmpty ? task.category : 'Uncategorized';
          if (categoryCount.containsKey(category)) {
            categoryCount[category] = categoryCount[category]! + 1;
          } else {
            categoryCount[category] = 1;
          }
        }

        // Sort by count
        final sortedEntries = categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Get top 5 categories
        final topCategories = sortedEntries.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Category Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topCategories.length,
                  itemBuilder: (context, index) {
                    final entry = topCategories[index];
                    final categoryName = entry.key;
                    final taskCount = entry.value;
                    final percentage =
                        (taskCount / tasks.length * 100).toStringAsFixed(1);

                    // Find the color for this category
                    Color categoryColor = Colors.grey;
                    for (var category in AppTheme.predefinedCategories) {
                      if (category['name'] == categoryName) {
                        categoryColor = category['color'] as Color;
                        break;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        categoryName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$percentage% ($taskCount)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: taskCount / tasks.length,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(categoryColor),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn()
                        .slideX(
                          begin: 0.05,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutQuad,
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
