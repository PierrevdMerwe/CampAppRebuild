// lib/src/campsite_owner/widgets/dashboard_section_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Widget? trailing;

  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.children,
    required this.onTap,
    this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: backgroundColor ?? Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// lib/src/campsite_owner/widgets/info_item.dart
class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? const Color(0xff2e6f40),
          size: 24,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}