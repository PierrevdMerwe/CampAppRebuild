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

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _usernameController = TextEditingController(text: user?.username);
    _userNumberController = TextEditingController(text: user?.userNumber);
    _joinedController = TextEditingController(
      text: user?.createdAt != null
          ? DateFormat('dd MMMM yyyy').format(user!.createdAt)
          : '',
    );
    _loadProfileIcon();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _userNumberController.dispose();
    _joinedController.dispose();
    super.dispose();
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

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Account',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
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
      // Only update allowed fields
      await context.read<UserProvider>().updateUserProfile(
        name: _nameController.text,
        username: _usernameController.text,
      );

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
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Update Profile',
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
                    // Only show delete button if user is logged in
                    if (userProvider.user == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          width: double.infinity, // Same width as update button
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _showDeleteAccountDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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
                      ],
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