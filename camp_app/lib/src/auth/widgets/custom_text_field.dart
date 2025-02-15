// lib/src/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled; // Add this line

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true, // Add this line with a default value
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled, // Add this line
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.montserrat(
          color: enabled ? AppColors.primary : Colors.grey, // Update this line
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: enabled ? AppColors.primary : Colors.grey, // Update this line
        ),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: enabled ? AppColors.primary : Colors.grey, // Update this line
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled ? AppColors.primary : Colors.grey, // Update this line
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled ? AppColors.primary : Colors.grey, // Update this line
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder( // Add this
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: !enabled, // Add this
        fillColor: enabled ? Colors.transparent : Colors.grey.withOpacity(0.1), // Add this
      ),
      style: GoogleFonts.montserrat(
        color: enabled ? Colors.black : Colors.grey, // Update this line
      ),
    );
  }
}