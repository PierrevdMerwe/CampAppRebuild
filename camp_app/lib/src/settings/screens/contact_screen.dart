// lib/src/settings/screens/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/widgets/social_footer.dart';
import '../../shared/constants/app_colors.dart';
import 'dart:developer' as developer;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Selected inquiry type
  String? _selectedInquiryType;

  // Inquiry type options
  final List<String> _inquiryTypes = [
    'General Inquiry',
    'Technical Support',
    'Campsite Listing',
    'Billing Question',
    'Feedback/Suggestion',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Debug log for form submission
      developer.log('📨 Contact form submitted:', name: 'ContactScreen');
      developer.log('  Name: ${_nameController.text}', name: 'ContactScreen');
      developer.log('  Email: ${_emailController.text}', name: 'ContactScreen');
      developer.log('  Phone: ${_phoneController.text}', name: 'ContactScreen');
      developer.log('  Inquiry Type: $_selectedInquiryType',
          name: 'ContactScreen');
      developer.log('  Message: ${_messageController.text}',
          name: 'ContactScreen');

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xffF5F8F5),
              title: Text(
                'Message Sent!',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              content: Text(
                'Thank you for contacting us. Our team will get back to you shortly.',
                style: GoogleFonts.montserrat(),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff2e6f40),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Clear form fields
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                    _messageController.clear();
                    setState(() {
                      _selectedInquiryType = null;
                    });
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact form header
                    Text(
                      'Get in Touch',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Have a question or need assistance? Send us a message and we\'ll get back to you as soon as possible.',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Email validation regex
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field (optional)
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Optional)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Basic phone validation
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Inquiry type
                    Text(
                      'What can we help you with?',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Radio buttons for inquiry type
                    ..._inquiryTypes.map(_buildInquiryTypeRadio),

                    if (_selectedInquiryType == null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          'Please select an inquiry type',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.red[400],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Message field
                    _buildTextField(
                      controller: _messageController,
                      label: 'Your Message',
                      icon: Icons.message_outlined,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        if (value.length < 10) {
                          return 'Message must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Send Message',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          const SocialFooter(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
      ),
      style: GoogleFonts.montserrat(),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildInquiryTypeRadio(String type) {
    return RadioListTile<String>(
      title: Text(
        type,
        style: GoogleFonts.montserrat(),
      ),
      value: type,
      groupValue: _selectedInquiryType,
      activeColor: AppColors.primary,
      onChanged: (value) {
        setState(() {
          _selectedInquiryType = value;
        });
      },
    );
  }
}
