// lib/src/auth/screens/account_linking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/user_provider.dart';
import '../services/account_linking_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';
import '../services/auth_service.dart';
import '../services/site_owner_service.dart';
import '../../utils/form_validators.dart';
import '../../utils/auth_utils.dart';
import './pending_verification.dart';

class AccountLinkingScreen extends StatefulWidget {
  final bool isLinkingToOwner; // true if camper linking to owner, false if owner linking to camper

  const AccountLinkingScreen({
    Key? key,
    required this.isLinkingToOwner,
  }) : super(key: key);

  @override
  _AccountLinkingScreenState createState() => _AccountLinkingScreenState();
}

class _AccountLinkingScreenState extends State<AccountLinkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _campsiteNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authService = AuthService();
  final _siteOwnerService = SiteOwnerService();
  bool _isCampsiteNameTaken = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Password validation states
  bool _isPasswordLengthValid = false;
  bool _isPasswordUppercaseValid = false;
  bool _isPasswordLowercaseValid = false;
  bool _isPasswordNumberValid = false;
  bool _isPasswordSpecialCharValid = false;

  @override
  void initState() {
    super.initState();
    // We intentionally don't pre-fill the email address because
    // each account must have a unique email address
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      // Optionally pre-fill the name for owner->camper linking
      if (!widget.isLinkingToOwner) {
        _nameController.text = userProvider.user!.name;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _campsiteNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Add these methods to the _AccountLinkingScreenState class

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || !_isPasswordValid()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = Provider.of<UserProvider>(context, listen: false).user;

      if (currentUser == null) {
        throw 'User not logged in';
      }

      if (widget.isLinkingToOwner) {
        // Camper linking to owner

        // First check if campsite name is unique
        if (!await _siteOwnerService.isCampsiteNameUnique(_campsiteNameController.text)) {
          setState(() {
            _isCampsiteNameTaken = true;
            _isLoading = false;
          });
          return;
        }

        // Create new site owner account
        final ownerCredential = await _authService.registerWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          name: _campsiteNameController.text,
          isCampOwner: true,
          phone: _phoneController.text,
          campsiteName: _campsiteNameController.text,
          linkToCamperUid: currentUser.uid, // Add this to ensure they're linked
        );

        // Make sure the ownerCredential exists and has a user
        if (ownerCredential?.user != null) {
          // Link accounts in Firestore
          final linkingService = AccountLinkingService();
          await linkingService.linkCamperToOwner(
              currentUser.uid,
              ownerCredential!.user!.uid
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PendingVerificationScreen(
                status: 'pending',
              ),
            ),
          );
        }
      } else {
        // Owner linking to camper

        // Create new camper account
        final camperCredential = await _authService.registerWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          displayName: _nameController.text,
          username: _usernameController.text,
          isCampOwner: false,
          linkToOwnerUid: currentUser.uid, // Add this to ensure they're linked
        );

        // Make sure the camperCredential exists and has a user
        if (camperCredential?.user != null) {
          // Link accounts in Firestore
          final linkingService = AccountLinkingService();
          await linkingService.linkCamperToOwner(
              camperCredential!.user!.uid,
              currentUser.uid
          );
        }

        if (mounted) {
          Navigator.pop(context);
          AuthUtils.showSuccessSnackbar(context, 'Accounts linked successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        AuthUtils.showErrorSnackbar(context, e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCamperForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          labelText: 'Full Name',
          prefixIcon: Icons.person,
          validator: (value) =>
          value?.isEmpty ?? true ? 'Name is required' : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _usernameController,
          labelText: 'Username',
          prefixIcon: Icons.alternate_email,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Username is required';
            }
            if (value!.contains(' ')) {
              return 'Username cannot contain spaces';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
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
        const SizedBox(height: 30),
        AuthButton(
          text: 'Link Accounts',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildOwnerForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _campsiteNameController,
          labelText: 'Campsite Name',
          prefixIcon: Icons.bungalow,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Campsite name is required';
            }
            if (_isCampsiteNameTaken) {
              return 'This campsite is already registered';
            }
            return null;
          },
          onChanged: (value) async {
            if (value.isNotEmpty) {
              final isUnique = await _siteOwnerService.isCampsiteNameUnique(value);
              if (mounted) {
                setState(() {
                  _isCampsiteNameTaken = !isUnique;
                });
              }
            }
          },
        ),
        if (_isCampsiteNameTaken) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'This campsite is already registered - ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
                InkWell(
                  onTap: _launchSupport,
                  child: Text(
                    'Contact our support team',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        CustomTextField(
          controller: _phoneController,
          labelText: 'Contact Number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) =>
          value?.isEmpty ?? true ? 'Phone number is required' : null,
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
        const SizedBox(height: 30),
        AuthButton(
          text: 'Link Accounts',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  void _validatePassword(String password) {
    setState(() {
      _isPasswordLengthValid = password.length >= 8;
      _isPasswordUppercaseValid = password.contains(RegExp(r'[A-Z]'));
      _isPasswordLowercaseValid = password.contains(RegExp(r'[a-z]'));
      _isPasswordNumberValid = password.contains(RegExp(r'[0-9]'));
      _isPasswordSpecialCharValid = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid() {
    return _isPasswordLengthValid &&
        _isPasswordUppercaseValid &&
        _isPasswordLowercaseValid &&
        _isPasswordNumberValid &&
        _isPasswordSpecialCharValid;
  }

  void _launchSupport() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support.thecampp@gmail.com',
      query: 'subject=Account Linking Request',
    );
    launchUrl(emailLaunchUri);
  }

  Widget _buildDisclaimerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.isLinkingToOwner
                ? 'If you have previously created a campsite owner account, please contact our support team to link your existing accounts.'
                : 'If you already have a camper account and want to link it, please contact our support team for assistance.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please use a different email address than your current account. Each account requires a unique email.',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _launchSupport,
            child: Text(
              'Contact Support',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
                decoration: TextDecoration.underline,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isLinkingToOwner ? 'Link to Owner Account' : 'Link to Camper Account',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lottie animation at the top
              Center(
                child: Lottie.asset(
                  'assets/sign.json',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isLinkingToOwner
                    ? 'Let\'s help you link to an owner profile'
                    : 'Let\'s help you link to a camper profile',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDisclaimerCard(),
              Form(
                key: _formKey,
                child: widget.isLinkingToOwner
                    ? _buildOwnerForm()
                    : _buildCamperForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}