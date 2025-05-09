import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart' show Iconsax;
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/task_form_bottom_sheet.dart';
import '../widgets/task_item.dart';
import 'task_detail_screen.dart';
import 'category_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeTab(),
    const CategoryScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // This is for the tab controller within the home tab
      });
    });

    // Load tasks when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskFormBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: _showAddTaskBottomSheet,
        label: const Text('Add Task'),
        icon: const Icon(Iconsax.add),
      ).animate(
        effects: [
          ScaleEffect(
            duration: 300.ms,
            curve: Curves.easeOut,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            duration: 300.ms,
            curve: Curves.easeOut,
            begin: 0.0,
            end: 1.0,
          ),
        ],
        autoPlay: true,
        delay: 300.ms,
      )
          : null,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Iconsax.home, 'Home'),
              _buildNavItem(1, Iconsax.category, 'Categories'),
              _buildNavItem(2, Iconsax.chart, 'Analytics'),
              _buildNavItem(3, Iconsax.setting, 'Settings'),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
        begin: 0.1,
        end: 0,
        duration: 300.ms,
        curve: Curves.easeOutQuad,
        delay: 200.ms,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == _selectedIndex;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Tab - contains the task lists with tabs
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskFormBottomSheet(),
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

  // Fixed tab item to prevent overflow - using Flexible to avoid overflow
  Widget _buildTabItem(IconData icon, String label, bool isSelected) {
    return Tab(
      height: 44,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 14, // Reduced size further
          ),
          const SizedBox(width: 2), // Reduced spacing
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12, // Further reduced font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task Manager',
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
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: Icon(
                        Iconsax.user,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(
                      begin: 0.1,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutQuad,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your tasks efficiently',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
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

          // Tab Bar - Fixed to prevent overflow
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: BorderRadius.circular(16),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12, // Reduced font size
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12, // Reduced font size
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              labelPadding: EdgeInsets.zero, // Remove padding to save space
              tabs: [
                _buildTabItem(Iconsax.calendar_search5, 'All', _tabController.index == 0),
                _buildTabItem(Iconsax.calendar_tick, 'Today', _tabController.index == 1),
                _buildTabItem(Iconsax.calendar, 'Upcoming', _tabController.index == 2),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
            begin: -0.1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOutQuad,
            delay: 150.ms,
          ),

          const SizedBox(height: 16),

          // Task Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Tasks Tab
                _buildTaskList((taskProvider) => taskProvider.tasks),

                // Today's Tasks Tab
                _buildTaskList((taskProvider) => taskProvider.todayTasks),

                // Upcoming Tasks Tab
                _buildTaskList((taskProvider) => taskProvider.upcomingTasks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> Function(TaskProvider) taskSelector) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskSelector(taskProvider);

        if (tasks.isEmpty) {
          return _buildEmptyTaskList();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItemWidget(
              task: task,
              onTap: () => _navigateToTaskDetail(task),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyTaskList() {
    String message = 'No tasks yet';
    String subMessage = 'Add your first task by tapping the button below';

    if (_selectedIndex == 1) {
      message = 'No tasks for today';
      subMessage = 'Take a break or add some tasks for today';
    } else if (_selectedIndex == 2) {
      message = 'No upcoming tasks';
      subMessage = 'Your schedule is clear for the upcoming days';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.add_circle,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            curve: Curves.elasticOut,
            duration: 750.ms,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddTaskBottomSheet,
            icon: const Icon(Iconsax.add),
            label: const Text('Add New Task'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}