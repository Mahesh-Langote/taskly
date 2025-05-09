import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/category_distribution.dart';
import '../widgets/priority_chart.dart';
import '../widgets/section_divider.dart';
import '../widgets/task_completion_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.1),
                      theme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
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
                      'Track your productivity insights',
                      style: TextStyle(
                        fontSize: 16,
                        color: subTextColor,
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

              const SizedBox(height: 20),

              // Summary Cards
              const AnalyticsSummaryCards(),

              const SectionDivider(),

              // Task Completion Chart
              const TaskCompletionChart(),

              const SectionDivider(),

              // Category Distribution
              const CategoryDistribution(),

              const SectionDivider(),

              // Priority Distribution
              const PriorityChart(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
