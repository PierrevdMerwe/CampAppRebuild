import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../core/config/theme/theme_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../core/services/profile_icon_service.dart';

class OwnerPersonalInfoScreen extends StatefulWidget {
  const OwnerPersonalInfoScreen({super.key});

  @override
  State<OwnerPersonalInfoScreen> createState() =>
      _OwnerPersonalInfoScreenState();
}

class _OwnerPersonalInfoScreenState extends State<OwnerPersonalInfoScreen> {
  late TextEditingController _campsiteNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _joinedController;
  bool _isLoading = false;
  final ProfileIconService _profileIconService = ProfileIconService();
  Map<String, dynamic>? _profileIconData;
  bool _isLoadingIcon = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _campsiteNameController = TextEditingController(
        text: user?.name); // Using name which contains campsite_name
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(
        text: user?.userNumber); // This will be the phone number
    _joinedController = TextEditingController(
      text: user?.createdAt != null
          ? DateFormat('dd MMMM yyyy').format(user!.createdAt)
          : '',
    );
    _loadProfileIcon();
  }

  @override
  void dispose() {
    _campsiteNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<UserProvider>().updateUserProfile(
            name: _campsiteNameController.text,
            username:
                _campsiteNameController.text, // Using campsite name as username
            phone: _phoneController.text,
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
                                    : const FaIcon(
                                  FontAwesomeIcons.tent,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              // Remove the camera icon position since we don't allow uploads anymore
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _campsiteNameController,
                          labelText: 'Campsite Name',
                          prefixIcon: FontAwesomeIcons.tent,
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
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
                                onTap: () {
                                  final Uri emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'support.thecampp@gmail.com',
                                    query: 'subject=Email Change Request',
                                  );
                                  launchUrl(emailLaunchUri);
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
                          controller: _phoneController,
                          labelText: 'Phone',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
