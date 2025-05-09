import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings variables
  bool _enableNotifications = true;
  bool _enableCloudSync = true;
  String _selectedLanguage = 'English';

  // List of available languages
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _enableCloudSync = !(prefs.getBool('isOfflineMode') ?? false);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setString('language', _selectedLanguage);
  }

  Future<void> _toggleCloudSync(bool value) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // If enabling cloud sync and not logged in, redirect to login
    if (value && !authService.isLoggedIn) {
      final shouldLogin = await _showCloudSyncLoginDialog();
      if (shouldLogin) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
      return;
    }

    // Set offline mode to the opposite of cloud sync
    await authService.setOfflineMode(!value);
    setState(() {
      _enableCloudSync = value;
    });

    // Trigger sync if cloud sync is enabled
    if (value && authService.isLoggedIn) {
      taskProvider.syncWithCloud();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Cloud sync enabled. Your tasks will be synchronized across devices.'
            : 'Cloud sync disabled. Your tasks will be stored locally only.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _showCloudSyncLoginDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in Required'),
        content: const Text(
            'Cloud sync requires an account. Would you like to sign in or create an account now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final showCompletedTasks = taskProvider.showCompletedTasks;
    final isLoggedIn = authService.isLoggedIn;
    final user = authService.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
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
                      'Customize your app preferences',
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
              const SizedBox(height: 8),
              _buildSettingsSection(
                title: isLoggedIn ? 'Account' : 'Cloud Sync',
                icon: isLoggedIn ? Iconsax.personalcard : Iconsax.cloud,
                iconColor: Colors.indigo,
                children: isLoggedIn
                    ? [
                        _buildAccountInfo(user?.displayName, user?.email),
                        _buildSwitchSetting(
                          title: 'Cloud Synchronization',
                          subtitle: 'Sync your tasks across devices',
                          value: _enableCloudSync,
                          onChanged: (value) => _toggleCloudSync(value),
                        ),
                        _buildActionSetting(
                          title: 'Sync Now',
                          subtitle: 'Force sync with cloud',
                          icon: Iconsax.cloud,
                          onTap: () {
                            if (_enableCloudSync) {
                              taskProvider.syncWithCloud();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Synchronization in progress...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enable cloud sync first'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        _buildActionSetting(
                          title: 'Sign Out',
                          subtitle: 'Log out from your account',
                          icon: Iconsax.logout,
                          onTap: () => _showSignOutConfirmationDialog(),
                        ),
                      ]
                    : [
                        _buildCloudSyncInfoCard(),
                        _buildActionSetting(
                          title: 'Sign In or Create Account',
                          subtitle: 'Enable cloud synchronization',
                          icon: Iconsax.login,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ],
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(
                title: 'Appearance',
                icon: Iconsax.designtools,
                iconColor: Colors.purple,
                children: [
                  _buildSwitchSetting(
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme for the app',
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  _buildLanguageSelector(),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(
                title: 'Notifications',
                icon: Iconsax.notification,
                iconColor: Colors.amber,
                children: [
                  _buildSwitchSetting(
                    title: 'Enable Notifications',
                    subtitle: 'Receive reminders about your tasks',
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                        _saveSettings();
                      });
                      _showFeatureNotImplementedSnackbar();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(
                title: 'Tasks',
                icon: Iconsax.edit,
                iconColor: Colors.teal,
                children: [
                  _buildSwitchSetting(
                    title: 'Show Completed Tasks',
                    subtitle: 'Display completed tasks in task lists',
                    value: showCompletedTasks,
                    onChanged: (value) {
                      taskProvider.setShowCompletedTasks(value);
                    },
                  ),
                  _buildActionSetting(
                    title: 'Clear Completed Tasks',
                    subtitle: 'Remove all completed tasks from the list',
                    icon: Iconsax.empty_wallet,
                    onTap: () => _showClearCompletedTasksDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(
                title: 'About',
                icon: Iconsax.information,
                iconColor: Colors.blue,
                children: [
                  _buildActionSetting(
                    title: 'App Version',
                    subtitle: '1.0.0',
                    icon: Iconsax.setting,
                    onTap: () {},
                  ),
                  _buildActionSetting(
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    icon: Iconsax.document,
                    onTap: () => _showFeatureNotImplementedSnackbar(),
                  ),
                  _buildActionSetting(
                    title: 'Terms of Service',
                    subtitle: 'Read our terms of service',
                    icon: Iconsax.document,
                    onTap: () => _showFeatureNotImplementedSnackbar(),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _buildActionButton(
                      label: 'Export Data',
                      icon: Iconsax.export,
                      color: Colors.indigo,
                      onTap: () => _showFeatureNotImplementedSnackbar(),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: 'Delete All Tasks',
                      icon: Iconsax.trash,
                      color: Colors.red,
                      onTap: () => _showDeleteConfirmationDialog(),
                    ),
                    if (!isLoggedIn) ...[
                      const SizedBox(height: 24),
                      _buildActionButton(
                        label: 'Sign In / Register',
                        icon: Icons.login,
                        color: Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String? displayName, String? email) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              displayName != null && displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : email != null && email.isNotEmpty
                      ? email[0].toUpperCase()
                      : 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email != null && email.isNotEmpty)
                  Text(
                    email,
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
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text(
        'Language',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Select your preferred language',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        ),
      ),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(),
        items: _languages.map((language) {
          return DropdownMenuItem(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedLanguage = value;
              _saveSettings();
            });
            _showFeatureNotImplementedSnackbar();
          }
        },
      ),
    );
  }

  Widget _buildActionSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(color: color),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCloudSyncInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cloud Synchronization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re currently using the app without an account. Your tasks are only stored on this device.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to sync your tasks across devices and never lose your data.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotImplementedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature will be implemented in a future update'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Tasks'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              final taskProvider =
                  Provider.of<TaskProvider>(context, listen: false);
              taskProvider.deleteAllTasks();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All tasks have been deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedTasksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(
          'Are you sure you want to remove all completed tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              final taskProvider =
                  Provider.of<TaskProvider>(context, listen: false);
              taskProvider.deleteCompletedTasks();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed tasks have been removed'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
