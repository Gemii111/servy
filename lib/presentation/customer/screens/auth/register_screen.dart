import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Register screen for Customer app
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.userType = 'customer'});

  final String userType;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: widget.userType,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to home based on **actual** user type returned from backend
      final user = ref.read(currentUserProvider);
      switch (user?.userType) {
        case 'driver':
          context.go('/driver/home');
          break;
        case 'restaurant':
          context.go('/restaurant/home');
          break;
        case 'customer':
        default:
          context.go('/customer/home');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-type-selection');
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surface.withOpacity(0.5),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // App Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 50,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Glass Card Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // User Type Indicator
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getUserTypeColor(widget.userType).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getUserTypeIcon(widget.userType),
                                      size: 20,
                                      color: _getUserTypeColor(widget.userType),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getUserTypeLabel(widget.userType, l10n),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getUserTypeColor(widget.userType),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        context.push('/user-type-selection');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        l10n.change,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Title
                            Text(
                              l10n.createAccount,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.signUpToGetStarted,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            // Name field
                            CustomTextField(
                              controller: _nameController,
                              labelText: l10n.name,
                              hintText: l10n.enterYourName,
                              prefixIcon: const Icon(Icons.person_outlined),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  Validators.validateRequired(value, l10n.name.toLowerCase()),
                            ),
                            const SizedBox(height: 18),
                            // Email field
                            CustomTextField(
                              controller: _emailController,
                              labelText: l10n.email,
                              hintText: l10n.enterYourEmail,
                              prefixIcon: const Icon(Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 18),
                            // Phone field
                            CustomTextField(
                              controller: _phoneController,
                              labelText: l10n.phone,
                              hintText: l10n.enterYourPhone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validatePhone,
                            ),
                            const SizedBox(height: 18),
                            // Password field
                            CustomTextField(
                              controller: _passwordController,
                              labelText: l10n.password,
                              hintText: l10n.enterYourPassword,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 18),
                            // Confirm password field
                            CustomTextField(
                              controller: _confirmPasswordController,
                              labelText: l10n.confirmPassword,
                              hintText: l10n.confirmYourPassword,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              validator: (value) => Validators.validateConfirmPassword(
                                    _passwordController.text,
                                    value,
                                  ),
                              onSubmitted: (_) => _handleRegister(),
                            ),
                            const SizedBox(height: 28),
                            // Register button
                            CustomButton(
                              text: l10n.register,
                              onPressed: _handleRegister,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 24),
                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.go('/login?type=${widget.userType}');
                                  },
                                  child: Text(
                                    l10n.login,
                                    style: const TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Switch user type
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.push('/user-type-selection');
                                },
                                child: Text(
                                  l10n.switchUserType,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case 'customer':
        return Icons.shopping_bag;
      case 'driver':
        return Icons.local_shipping;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.person;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'customer':
        return AppColors.primary;
      case 'driver':
        return AppColors.accent;
      case 'restaurant':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getUserTypeLabel(String userType, AppLocalizations l10n) {
    switch (userType) {
      case 'customer':
        return l10n.customer;
      case 'driver':
        return l10n.driver;
      case 'restaurant':
        return l10n.restaurant;
      default:
        return 'User';
    }
  }
}


