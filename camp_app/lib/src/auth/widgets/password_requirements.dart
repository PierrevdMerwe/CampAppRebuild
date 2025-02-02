import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({
    required this.text,
    required this.isMet,
  });
}

class PasswordRequirementsList extends StatelessWidget {
  final List<PasswordRequirement> requirements;

  const PasswordRequirementsList({
    super.key,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((requirement) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                requirement.isMet ? Icons.check_circle : Icons.circle_outlined,
                color: requirement.isMet ? const Color(0xff2e6f40) : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                requirement.text,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: requirement.isMet ? const Color(0xff2e6f40) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}