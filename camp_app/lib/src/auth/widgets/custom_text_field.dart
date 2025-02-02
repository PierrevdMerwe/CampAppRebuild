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
  final void Function(String)? onChanged; // Add this line

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.validator,
    this.onChanged, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged, // Add this line
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.montserrat(color: AppColors.primary),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      style: GoogleFonts.montserrat(),
    );
  }
}