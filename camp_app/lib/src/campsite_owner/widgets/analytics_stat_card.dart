import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A reusable card for displaying analytics statistics.
class AnalyticsStatCard extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final bool showShadow;
  final double borderRadius;
  final Widget? headerTrailing;

  const AnalyticsStatCard({
    Key? key,
    required this.title,
    required this.content,
    this.padding = const EdgeInsets.all(16),
    this.contentPadding = const EdgeInsets.only(top: 16),
    this.showShadow = true,
    this.borderRadius = 12,
    this.headerTrailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: showShadow ? 2 : 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: showShadow ? Colors.transparent : Colors.grey.withValues(alpha: .2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and optional trailing widget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),

            // Content section
            Padding(
              padding: contentPadding,
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

/// A summary card for displaying a key metric.
class StatSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;
  final double? height;

  const StatSummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying an insight message with an appropriate icon.
class InsightMessage extends StatelessWidget {
  final String message;
  final InsightStatus status;

  const InsightMessage({
    Key? key,
    required this.message,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color iconColor;
    final IconData icon;

    // Use our app's green colors for all statuses
    const Color positiveBackgroundColor = Color(0xFFF6FFED); // Light green
    const Color moderateBackgroundColor = Color(0xFFFFFBE6); // Light yellow/amber
    const Color negativeBackgroundColor = Color(0xFFFFF1F0); // Light red

    switch (status) {
      case InsightStatus.positive:
        backgroundColor = positiveBackgroundColor;
        iconColor = const Color(0xff2e6f40); // App green
        icon = FontAwesomeIcons.thumbsUp;
        break;
      case InsightStatus.moderate:
        backgroundColor = moderateBackgroundColor;
        iconColor = Colors.amber[700]!;
        icon = FontAwesomeIcons.handsHolding;
        break;
      case InsightStatus.negative:
        backgroundColor = negativeBackgroundColor;
        iconColor = Colors.red[700]!;
        icon = FontAwesomeIcons.thumbsDown;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FaIcon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRichText(message, iconColor),
          ),
        ],
      ),
    );
  }

  // Parse the message and build rich text with highlights
  Widget _buildRichText(String message, Color highlightColor) {
    // Check if message contains any highlighted tags
    if (!message.contains('<b>')) {
      return Text(
        message,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: Colors.black87,
        ),
      );
    }

    // Split the message to extract highlighted parts
    final List<InlineSpan> spans = [];
    final RegExp exp = RegExp(r'<b>(.*?)</b>');
    int lastIndex = 0;

    for (final Match match in exp.allMatches(message)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: message.substring(lastIndex, match.start),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: highlightColor,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add any remaining text
    if (lastIndex < message.length) {
      spans.add(
        TextSpan(
          text: message.substring(lastIndex),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}


enum InsightStatus {
  positive,
  moderate,
  negative,
}

/// A widget for displaying rating distribution bars.
class RatingDistributionBar extends StatelessWidget {
  final int rating;
  final int count;
  final int totalCount;

  const RatingDistributionBar({
    Key? key,
    required this.rating,
    required this.count,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalCount > 0 ? (count / totalCount * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 15,
            child: Text(
              '$rating',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[300],
                color: const Color(0xFFFFD700),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '($count)',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}