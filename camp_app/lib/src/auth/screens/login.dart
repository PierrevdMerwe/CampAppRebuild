// lib/src/auth/screens/login_screen.dart
import 'package:camp_app/src/auth/screens/pending_verification.dart';
import 'package:camp_app/src/auth/screens/register.dart';
import 'package:flutter/material.dart';
import '../../../preferences.dart';
import '../../utils/auth_utils.dart';
import '../services/auth_service.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/user_type_toggle.dart';
import '../widgets/social_login_buttons.dart';
import '../../utils/form_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _userType = 'Camper';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (_userType == 'Campsite Owner' && !result['is_site_owner']) {
          AuthUtils.showErrorSnackbar(context, 'This account is not registered as a campsite owner');
          return;
        }

        if (_userType == 'Camper' && result['is_site_owner']) {
          AuthUtils.showErrorSnackbar(context, 'This account is not registered as a camper');
          return;
        }

        if (result['is_site_owner']) {
          final verificationStatus = result['verification_status'];
          if (verificationStatus != null && !verificationStatus['verified']) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PendingVerificationScreen(
                  status: verificationStatus['status'],
                ),
              ),
            );
            return;
          }
        }

        AuthUtils.showSuccessSnackbar(context, 'Successfully logged in!');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesScreen()),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        AuthUtils.showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // In login.dart
  Future<void> _handleAppleSignIn() async {
    if (_userType == 'Campsite Owner') {
      AuthUtils.showErrorSnackbar(
          context, 'Campsite owners must register with email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithApple(userType: _userType);

      if (mounted) {
        AuthUtils.showSuccessSnackbar(context, 'Successfully logged in!');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesScreen()),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        AuthUtils.showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_userType == 'Campsite Owner') {
      AuthUtils.showErrorSnackbar(
          context,
          'Campsite owners must register with email and password'
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (mounted) {
        AuthUtils.showSuccessSnackbar(context, 'Successfully logged in!');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesScreen()),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        AuthUtils.showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Please Complete Setup'),
            content: const Text(
              'Please complete the setup process first, any and all settings can be changed after initial setup.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      ),
      child: AuthLayout(
        title: 'Login',
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                UserTypeToggle(
                  selectedType: _userType,
                  onTypeChanged: (type) => setState(() => _userType = type),
                  isRegister: false,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  validator: FormValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: FormValidators.validatePassword,
                ),
                const SizedBox(height: 30),
                AuthButton(
                  text: 'Sign in',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                if (_userType != 'Campsite Owner') ...[
                  const SizedBox(height: 20),
                  SocialLoginButtons(
                    onGooglePressed: _handleGoogleSignIn,
                    onApplePressed: _handleAppleSignIn,
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                _buildRegisterLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            'Register',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}