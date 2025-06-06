import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../core/config/theme/theme_model.dart';
import '../../shared/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/profile_icon_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _userNumberController;
  late TextEditingController _joinedController;
  bool _isLoading = false;
  final ProfileIconService _profileIconService = ProfileIconService();
  Map<String, dynamic>? _profileIconData;
  bool _isLoadingIcon = true;
  String? _originalName;
  String? _originalUsername;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _originalName = user?.name ?? '';
    _originalUsername = user?.username ?? '';

    _nameController = TextEditingController(text: _originalName);
    _emailController = TextEditingController(text: user?.email);
    _usernameController = TextEditingController(text: _originalUsername);
    _userNumberController = TextEditingController(text: user?.userNumber);
    _joinedController = TextEditingController(
      text: user?.createdAt != null
          ? DateFormat('dd MMMM yyyy').format(user!.createdAt)
          : '',
    );

    // Add listeners to track changes
    _nameController.addListener(_checkForChanges);
    _usernameController.addListener(_checkForChanges);

    _loadProfileIcon();
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _usernameController.removeListener(_checkForChanges);
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _userNumberController.dispose();
    _joinedController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final hasChanges = _nameController.text != _originalName ||
        _usernameController.text != _originalUsername;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _loadProfileIcon() async {
    setState(() {
      _isLoadingIcon = true;
    });

    try {
      final iconData = await _profileIconService.getUserProfileIcon();
      if (mounted) {
        setState(() {
          _profileIconData = iconData;
          _isLoadingIcon = false;
        });
      }
    } catch (e) {
      print('Error loading profile icon: $e');
      if (mounted) {
        setState(() {
          _isLoadingIcon = false;
        });
      }
    }
  }

  Future<void> _showUpdateConfirmationDialog() async {
    final currentName = _nameController.text;
    final currentUsername = _usernameController.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.pencil,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Update Profile',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please confirm your profile changes:',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (currentName != _originalName) ...[
                  _buildChangeRow(
                    'Full Name',
                    _originalName ?? '',
                    currentName,
                  ),
                  const SizedBox(height: 12),
                ],
                if (currentUsername != _originalUsername) ...[
                  _buildChangeRow(
                    'Username',
                    _originalUsername ?? '',
                    currentUsername,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                overlayColor: Colors.grey.withValues(alpha: 0.1),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _updateProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(FontAwesomeIcons.check, size: 18, color: Colors.white,),
              label: Text(
                'Update',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChangeRow(String label, String oldValue, String newValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Current',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      oldValue.isEmpty ? '(empty)' : oldValue,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: oldValue.isEmpty ? Colors.grey : Colors.black87,
                        fontStyle: oldValue.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'New',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newValue.isEmpty ? '(empty)' : newValue,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: newValue.isEmpty ? Colors.grey : Colors.black87,
                        fontStyle: newValue.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Account',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600], // Fix the purple highlight
                overlayColor: Colors.grey.withValues(alpha: 0.1), // Gray highlight on hover
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete_forever, size: 18, color: Colors.white,),
              label: Text(
                'Delete',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No user logged in';
      }

      // Clear user data from provider
      await context.read<UserProvider>().clearUserData();

      // Delete Firebase user account
      await user.delete();

      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<UserProvider>().updateUserProfile(
        name: _nameController.text,
        username: _usernameController.text,
      );

      // Update original values after successful update
      _originalName = _nameController.text;
      _originalUsername = _usernameController.text;
      _checkForChanges(); // This will disable the button again

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final isDark = themeModel.isDark;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Personal Information',
              style: GoogleFonts.montserrat(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: _isLoadingIcon
                                    ? AppColors.primary
                                    : Color(int.parse(
                                    "0x${_profileIconData?['background'] ?? 'FF2E6F40'}")),
                                child: _isLoadingIcon
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : _profileIconData != null
                                    ? FaIcon(
                                  _profileIconService.getIconData(
                                    _profileIconData!['icon'],
                                  ),
                                  size: 40,
                                  color: Colors.white,
                                )
                                    : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              // Remove the camera icon position since we don't allow uploads anymore
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          prefixIcon: Icons.alternate_email,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          enabled: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Wrap(
                            children: [
                              Icon(Icons.info_outline,
                                size: 12,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Please ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.red[400],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
                                    path: 'support.thecampp@gmail.com',
                                    query: 'subject=Email Change Request',
                                  );

                                  try {
                                    print('Attempting to launch email URL: ${emailUri.toString()}');

                                    if (await canLaunchUrl(emailUri)) {
                                      final launched = await launchUrl(emailUri);
                                      print('URL launch result: $launched');

                                      if (!launched) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Could not open email app. Please contact support.thecampp@gmail.com'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      // Show error if URL can't be launched
                                      print('canLaunchUrl returned false for: ${emailUri.toString()}');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Could not open email client. Please contact support.thecampp@gmail.com'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print('Error launching URL: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error opening email: $e. Please contact support.thecampp@gmail.com'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  'contact support',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.red[400],
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red[400],
                                  ),
                                ),
                              ),
                              Text(
                                ' if you wish to change your email',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.red[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _userNumberController,
                          labelText: 'User Number',
                          prefixIcon: Icons.tag,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _joinedController,
                          labelText: 'Joined',
                          prefixIcon: Icons.calendar_today,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_hasChanges) ? null : _showUpdateConfirmationDialog, // Changed this line
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasChanges ? AppColors.primary : Colors.grey, // Change color based on changes
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _hasChanges ? 'Update Profile' : 'No Changes Made', // Change text based on changes
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    if (userProvider.user == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16), // Only top padding
                      child: SizedBox(
                        height: 50, // Exact same height
                        width: double.infinity, // Exact same width
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _showDeleteAccountDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Exact same border radius
                            ),
                          ),
                          child: Text(
                            'Delete Account',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}