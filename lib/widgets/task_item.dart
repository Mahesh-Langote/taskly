import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskItemWidget extends StatelessWidget {
  final Task task;
  final Function()? onTap;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(task.id),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          dismissible: DismissiblePane(
            onDismissed: () => taskProvider.deleteTask(task.id),
            closeOnCancel: true,
            confirmDismiss: () async {
              return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Task'),
                          content: Text(
                              'Are you sure you want to delete this task?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      }) ??
                  false;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (_) => taskProvider.deleteTask(task.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => taskProvider.toggleTaskCompletion(task.id),
              backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: task.isCompleted ? Icons.replay : Icons.check,
              label: task.isCompleted ? 'Undo' : 'Complete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: task.isCompleted
                    ? theme.disabledColor.withOpacity(0.5)
                    : task.categoryColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Checkbox
                InkWell(
                  onTap: () => taskProvider.toggleTaskCompletion(task.id),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? task.categoryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: task.categoryColor,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: task.isCompleted
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : const SizedBox(width: 18, height: 18),
                  ),
                ),
                const SizedBox(width: 12),
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? theme.disabledColor
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: task.categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: _getDateColor(task.dueDate),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.getRelativeDateString(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDateColor(task.dueDate),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad),
    );
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
        return Colors.grey;
    }
  }

  Color _getDateColor(DateTime date) {
    if (AppDateUtils.isOverdue(date)) {
      return Colors.red;
    } else if (AppDateUtils.isToday(date)) {
      return Colors.blue;
    } else if (AppDateUtils.isTomorrow(date)) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}

