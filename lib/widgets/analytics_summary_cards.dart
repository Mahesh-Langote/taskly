import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  const AnalyticsSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final totalTasks = taskProvider.tasks.length;
        final completedTasks = taskProvider.completedTasks.length;
        final pendingTasks = taskProvider.pendingTasks.length;

        final completionRate = totalTasks > 0
            ? (completedTasks / totalTasks * 100).toStringAsFixed(0)
            : '0';

        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Tasks',
                      value: '$totalTasks',
                      icon: Iconsax.like,
                      color: theme.primaryColor,
                      cardColor: cardColor,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Rate',
                      value: '$completionRate%',
                      icon: Iconsax.chart,
                      color: Colors.green,
                      cardColor: cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Completed',
                      value: '$completedTasks',
                      icon: Iconsax.check,
                      color: Colors.teal,
                      cardColor: cardColor,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pending',
                      value: '$pendingTasks',
                      icon: Iconsax.transaction_minus,
                      color: Colors.orange,
                      cardColor: cardColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms);
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Color? cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor ?? Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}
