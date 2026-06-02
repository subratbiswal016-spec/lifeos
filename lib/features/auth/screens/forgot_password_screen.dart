import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isStepOne = true; // true = Enter Email, false = Verify OTP & Reset
  bool _isLoading = false;

  void _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.forgotPassword(email);
      
      setState(() {
        _isLoading = false;
        _isStepOne = false;
      });

      final receivedOtp = result['data']?['otp'];
      if (receivedOtp != null) {
        Fluttertoast.showToast(
          msg: 'OTP sent! Development OTP: $receivedOtp',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.indigo,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(msg: 'Reset code sent to console/logs');
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      final errorMsg = e.response?.data['message'] ?? e.message ?? 'Failed to send OTP';
      Fluttertoast.showToast(msg: errorMsg);
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    if (newPassword.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters long');
      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(email, otp, newPassword);

      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: 'Password reset successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      if (mounted) {
        context.go('/login');
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      final errorMsg = e.response?.data['message'] ?? e.message ?? 'Reset password failed';
      Fluttertoast.showToast(msg: errorMsg);
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textColor),
          onPressed: () {
            if (!_isStepOne) {
              setState(() => _isStepOne = true);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: PremiumBackground(
        showOrbs: true,
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: size.height - kToolbarHeight),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Iconsax.key_square,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _isStepOne ? 'Forgot Password' : 'Reset Password',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _isStepOne
                            ? 'Enter your email address to receive a 6-digit password reset OTP code.'
                            : 'Enter the verification OTP code and your new password.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(28),
                        child: _isStepOne
                            ? Column(
                                children: [
                                  AppTextField(
                                    label: 'Email Address',
                                    hint: 'Enter your email',
                                    controller: _emailController,
                                    prefixIcon: Iconsax.sms,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      text: 'Send Reset Code',
                                      onPressed: _sendOtp,
                                      isLoading: _isLoading,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  AppTextField(
                                    label: 'Verification OTP Code',
                                    hint: 'Enter 6-digit OTP',
                                    controller: _otpController,
                                    prefixIcon: Iconsax.code_1,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 20),
                                  AppTextField(
                                    label: 'New Password',
                                    hint: 'Enter new password',
                                    controller: _newPasswordController,
                                    prefixIcon: Iconsax.lock,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 20),
                                  AppTextField(
                                    label: 'Confirm New Password',
                                    hint: 'Re-enter new password',
                                    controller: _confirmPasswordController,
                                    prefixIcon: Iconsax.lock_1,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      text: 'Reset Password',
                                      onPressed: _resetPassword,
                                      isLoading: _isLoading,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
