import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(name, email, password);
    
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                theme.colorScheme.secondary.withOpacity(0.05),
                theme.colorScheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Icon(
                      Iconsax.profile_add,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'Create Account',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'Start organizing your life with LifeOS.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 800),
                    child: AppTextField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      controller: _nameController,
                      prefixIcon: Iconsax.user,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 800),
                    child: AppTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      prefixIcon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    duration: const Duration(milliseconds: 800),
                    child: AppTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      controller: _passwordController,
                      prefixIcon: Iconsax.lock,
                      isPassword: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 800),
                    child: AppButton(
                      text: 'Register',
                      onPressed: _register,
                      isLoading: authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    duration: const Duration(milliseconds: 800),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
