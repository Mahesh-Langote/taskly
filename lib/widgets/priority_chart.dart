import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'empty_chart_placeholder.dart';

class PriorityChart extends StatelessWidget {
  const PriorityChart({super.key});

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
              title: 'Priority Breakdown',
              message: 'No tasks available to analyze');
        }

        // Count tasks by priority
        int highPriority = 0;
        int mediumPriority = 0;
        int lowPriority = 0;

        for (var task in tasks) {
          switch (task.priority) {
            case 3:
              highPriority++;
              break;
            case 2:
              mediumPriority++;
              break;
            case 1:
              lowPriority++;
              break;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Priority Breakdown',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriorityItem(
                      icon: Iconsax.danger,
                      label: 'High',
                      count: highPriority,
                      color: Colors.red,
                      total: tasks.length,
                    ),
                    _buildPriorityItem(
                      icon: Iconsax.warning_2,
                      label: 'Medium',
                      count: mediumPriority,
                      color: Colors.orange,
                      total: tasks.length,
                    ),
                    _buildPriorityItem(
                      icon: Iconsax.tick_circle,
                      label: 'Low',
                      count: lowPriority,
                      color: Colors.green,
                      total: tasks.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _buildPriorityItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required int total,
  }) {
    final percentage = total > 0 ? (count / total * 100).toInt() : 0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: total > 0 ? count / total : 0,
                strokeWidth: 6,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(
              icon,
              size: 28,
              color: color,
            ),
          ],
        ).animate(delay: 200.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 600.ms,
            ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' ($percentage%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
