import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTypeToggle extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;
  final bool isRegister;

  const UserTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isRegister
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            isRegister ? 'Register as:' : 'Log in as:',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              // Animated selection indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: selectedType == 'Camper'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.43, // Adjust based on padding
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xff2e6f40),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              // Buttons row
              Row(
                children: [
                  _buildToggleButton('Camper'),
                  _buildToggleButton('Campsite Owner'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String type) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.montserrat(
            color: selectedType == type ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              type,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}