import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_completion_painter.dart';
import 'empty_chart_placeholder.dart';

class TaskCompletionChart extends StatelessWidget {
  const TaskCompletionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final completedTasks = taskProvider.completedTasks.length;
        final pendingTasks = taskProvider.pendingTasks.length;
        final totalTasks = completedTasks + pendingTasks;

        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        if (totalTasks == 0) {
          return const EmptyChartPlaceholder(
              title: 'Task Completion',
              message: 'No tasks available to analyze');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Task Completion',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: CustomPaint(
                        size: const Size(double.infinity, 220),
                        painter: TaskCompletionPainter(
                          completed: completedTasks,
                          pending: pendingTasks,
                          textColor: textColor,
                          completedColor: Colors.teal,
                          pendingColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChartLegend(
                          color: Colors.teal,
                          label: 'Completed ($completedTasks)',
                        ),
                        const SizedBox(width: 32),
                        _buildChartLegend(
                          color: Colors.orange,
                          label: 'Pending ($pendingTasks)',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  Widget _buildChartLegend({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
