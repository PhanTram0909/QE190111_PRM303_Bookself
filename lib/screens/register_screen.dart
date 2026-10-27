import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  String? _firebaseErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _firebaseErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.registrationSuccess),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      // Auth gate will automatically navigate to BooksListScreen or user can pop back
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _firebaseErrorMessage = authProvider.errorMessage ?? 'Registration failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Header
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join BookShelf to organize and track your personal library.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Email Field
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: AppValidators.validateRegisterPassword,
                    ),
                    const SizedBox(height: 18),

                    // Confirm Password Field
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitRegister(),
                      validator: (value) => AppValidators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Submit Button
                    AppButton(
                      text: 'Register',
                      onPressed: _submitRegister,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),

                    // Firebase errors shown on the form BELOW the submit button
                    if (_firebaseErrorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _firebaseErrorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Switch to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
