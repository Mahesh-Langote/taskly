import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _dontShowAgain = false;
  bool _hasShownOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownCloudSyncOnboarding') ?? false;

    // Check if the user is already logged in
    final authService = Provider.of<AuthService>(context, listen: false);

    if (hasShown || authService.isLoggedIn) {
      // If onboarding has been shown before or user is logged in,
      // navigate directly to home screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } else {
      setState(() {
        _hasShownOnboarding = true;
      });
    }
  }

  Future<void> _saveOnboardingPreference() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasShownCloudSyncOnboarding', true);
    }
  }

  void _navigateToLogin() {
    _saveOnboardingPreference();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _continueWithoutAccount() {
    _saveOnboardingPreference();

    // Set offline mode
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.setOfflineMode(true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _hasShownOnboarding
            ? _buildOnboardingContent()
            : _buildInitialSplash(),
      ),
    );
  }

  Widget _buildInitialSplash() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).primaryColor,
          ).animate().scale(duration: 700.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'Task Organizer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    // Wrap with SingleChildScrollView to handle overflow
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.cloud_sync,
              size: 80,
              color: Theme.of(context).primaryColor,
            ).animate().scale(duration: 700.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 30),
            Text(
              'Sync Your Tasks',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            const SizedBox(height: 16),
            Text(
              'Would you like to create an account to sync your tasks across multiple devices?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(duration: 800.ms, delay: 500.ms),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBenefitItem(
                    Icons.sync,
                    'Sync across devices',
                    'Access your tasks from any device',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    Icons.backup,
                    'Automatic backup',
                    'Never lose your task data',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    Icons.cloud_done,
                    'Always up-to-date',
                    'Changes sync automatically',
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 700.ms),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontShowAgain = value ?? false;
                    });
                  },
                ),
                const Text('Don\'t show this again'),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navigateToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text(
                'Sign in or Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 1100.ms),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _continueWithoutAccount,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text(
                'Continue without Account',
                style: TextStyle(fontSize: 16),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
