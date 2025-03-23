import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'analytics_stat_card.dart';

class EngagementSection extends StatelessWidget {
  final Map<String, dynamic> engagementData;

  const EngagementSection({
    Key? key,
    required this.engagementData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int totalFavorites = engagementData['totalFavorites'] ?? 0;
    final int totalReviews = engagementData['totalReviews'] ?? 0;
    final Map<String, dynamic> insight = engagementData['insights']?['engagement'] ??
        {'status': 'moderate', 'message': 'No insights available'};

    // Optional: Calculate and show growth if needed
    // final double favoritesGrowth = engagementData['favoritesGrowth'] ?? 0.0;

    return AnalyticsStatCard(
      title: 'Engagement',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorites
          _buildEngagementRow(
            FontAwesomeIcons.heart,
            'Favorites',
            'Users who saved your campsite',
            totalFavorites.toString(),
            Colors.pink,
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Reviews
          _buildEngagementRow(
            FontAwesomeIcons.comment,
            'Reviews',
            'Comments and ratings from users',
            totalReviews.toString(),
            Colors.orange,
          ),

          const SizedBox(height: 24),

          // Insight message
          InsightMessage(
            message: insight['message'],
            status: _getInsightStatus(insight['status']),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementRow(
      IconData icon,
      String title,
      String subtitle,
      String value,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InsightStatus _getInsightStatus(String status) {
    switch (status) {
      case 'positive':
        return InsightStatus.positive;
      case 'negative':
        return InsightStatus.negative;
      case 'moderate':
      default:
        return InsightStatus.moderate;
    }
  }
}