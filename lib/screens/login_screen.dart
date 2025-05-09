import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true; // Toggle between login and signup
  bool _isLoading = false;
  bool _isOfflineMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkOfflineMode();
  }

  Future<void> _checkOfflineMode() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isOffline = authService.isOfflineMode;

    setState(() {
      _isOfflineMode = isOffline;
      if (isOffline) {
        _errorMessage =
            'You are in offline mode. Authentication is unavailable. '
            'Please continue in offline mode or restart the app when internet is available.';
      }
    });
  }

  Future<void> _switchToOnlineMode() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Set offline mode to false
      await authService.setOfflineMode(false);

      setState(() {
        _isOfflineMode = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to switch to online mode: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isOfflineMode) {
      setState(() {
        _errorMessage = 'Authentication is unavailable in offline mode. '
            'Please continue in offline mode or restart the app when internet is available.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_isLogin) {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (mounted && authService.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getReadableErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isOfflineMode) {
      setState(() {
        _errorMessage = 'Authentication is unavailable in offline mode. '
            'Please continue in offline mode or restart the app when internet is available.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();

      if (mounted && authService.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getReadableErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueOffline() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.setOfflineMode(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  String _getReadableErrorMessage(String error) {
    if (error.contains('offline mode')) {
      return 'Authentication is unavailable in offline mode. '
          'Please continue in offline mode or restart the app when internet is available.';
    } else if (error.contains('user-not-found')) {
      return 'No user found with this email. Please sign up.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please log in.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format. Please check your email.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'An error occurred: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo / Title
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ).animate().fade(duration: 500.ms).scale(delay: 200.ms),

                const SizedBox(height: 24),

                // App Name
                Text(
                  'Task Organizer',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                )
                    .animate()
                    .fade(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 300.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  _isOfflineMode
                      ? 'Offline Mode'
                      : (_isLogin ? 'Welcome Back!' : 'Create an Account'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ).animate().fade(duration: 500.ms, delay: 400.ms),

                const SizedBox(height: 40),

                // Offline Mode Warning Banner
                if (_isOfflineMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off,
                            color: Colors.orange, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'You are in offline mode. Authentication and cloud sync features are unavailable.',
                          style: TextStyle(color: Colors.orange.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                // Error Message
                if (_errorMessage != null && !_isOfflineMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ).animate().shake(),

                if (_errorMessage != null && !_isOfflineMode)
                  const SizedBox(height: 20),

                // Form - Only show when not in offline mode
                if (!_isOfflineMode)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fade(delay: 500.ms),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ).animate().fade(delay: 600.ms),

                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Log In' : 'Sign Up'),
                        ).animate().fade(delay: 700.ms),

                        const SizedBox(height: 16),

                        // Toggle Button
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Sign up'
                                : 'Already have an account? Log in',
                          ),
                        ).animate().fade(delay: 800.ms),

                        const SizedBox(height: 32),

                        // OR Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ).animate().fade(delay: 900.ms),

                        const SizedBox(height: 24),

                        // Google Sign In Button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          icon: Image.network(
                            'https://www.gstatic.com/marketing-cms/assets/images/d5/dc/cfe9ce8b4425b410b49b7f2dd3f3/g.webp=s96-fcrop64=1,00000000ffffffff-rw',
                            height: 24,
                          ),
                          label: const Text('Continue with Google'),
                        ).animate().fade(delay: 1000.ms),

                        const SizedBox(height: 16),

                        // Offline Mode Button
                        TextButton(
                          onPressed: _isLoading ? null : _continueOffline,
                          child: const Text('Continue in Offline Mode'),
                        ).animate().fade(delay: 1100.ms),

                        // Add a button to switch to online mode
                        if (_isOfflineMode)
                          ElevatedButton(
                            onPressed: _switchToOnlineMode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Switch to Online Mode'),
                          ).animate().fade(delay: 1200.ms),
                      ],
                    ),
                  ),

                // If in offline mode, just show the "Continue in Offline Mode" button prominently
                if (_isOfflineMode)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _continueOffline,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Continue in Offline Mode'),
                      ).animate().scale(delay: 500.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Your tasks will be stored locally on this device only.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      Text(
                        'To enable cloud sync, please restart the app when you have an internet connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ).animate().fade(delay: 800.ms),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
