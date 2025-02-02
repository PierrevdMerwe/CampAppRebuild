// lib/src/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../preferences.dart';
import '../services/auth_service.dart';
import '../services/site_owner_service.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/user_type_toggle.dart';
import '../widgets/social_login_buttons.dart';
import '../../utils/form_validators.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  final _siteOwnerService = SiteOwnerService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _userType = 'Camper';

  // Password validation states
  bool _isPasswordLengthValid = false;
  bool _isPasswordUppercaseValid = false;
  bool _isPasswordLowercaseValid = false;
  bool _isPasswordNumberValid = false;
  bool _isPasswordSpecialCharValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePassword(String password) {
    setState(() {
      _isPasswordLengthValid = password.length >= 8;
      _isPasswordUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      _isPasswordLowercaseValid = password.contains(RegExp(r'[a-z]'));
      _isPasswordNumberValid = password.contains(RegExp(r'[0-9]'));
      _isPasswordSpecialCharValid =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid() {
    return _isPasswordLengthValid &&
        _isPasswordUppercaseValid &&
        _isPasswordLowercaseValid &&
        _isPasswordNumberValid &&
        _isPasswordSpecialCharValid;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || !_isPasswordValid()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.registerWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (userCredential != null) {
        if (_userType == 'Campsite Owner') {
          await _siteOwnerService.createSiteOwner(
            userCredential.user!.uid,
            _businessNameController.text,
            {
              'email': _emailController.text,
              'phone': _phoneController.text,
            },
          );
        }

        if (mounted) _showSuccessAndNavigate();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully registered!')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PreferencesScreen()),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _showExitDialog,
      child: AuthLayout(
        title: 'Register',
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                UserTypeToggle(
                  selectedType: _userType,
                  onTypeChanged: (type) => setState(() => _userType = type),
                  isRegister: true,
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
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (_) => _isPasswordValid() ? null : 'Invalid password',
                  onChanged: _validatePassword,
                ),
                _buildPasswordRequirements(),
                if (_userType == 'Campsite Owner') ...[
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _businessNameController,
                    labelText: 'Business Name',
                    prefixIcon: Icons.business,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Business name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Contact Number',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Phone number is required' : null,
                  ),
                ],
                const SizedBox(height: 30),
                AuthButton(
                  text: 'Register',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                SocialLoginButtons(
                  onGooglePressed: () {/* TODO */},
                  onApplePressed: () {/* TODO */},
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPasswordRequirements() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _passwordController.text.isEmpty ? 0 : 120,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildRequirement('At least 8 characters', _isPasswordLengthValid),
            _buildRequirement('One uppercase letter', _isPasswordUppercaseValid),
            _buildRequirement('One lowercase letter', _isPasswordLowercaseValid),
            _buildRequirement('One number', _isPasswordNumberValid),
            _buildRequirement('One special character', _isPasswordSpecialCharValid),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? const Color(0xff2e6f40) : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: isMet ? const Color(0xff2e6f40) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.montserrat(
            fontSize: 16.0,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Login',
            style: GoogleFonts.montserrat(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showExitDialog(bool didPop) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Please Complete Setup',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please complete the setup process first, any and all settings can be changed after initial setup.',
            style: GoogleFonts.montserrat(
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Ok',
                style: GoogleFonts.montserrat(
                  color: const Color(0xff2e6f40),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}