// lib/src/campsite_owner/widgets/views_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'analytics_stat_card.dart';
import 'monthly_trend_chart.dart';

class ViewsSection extends StatelessWidget {
  final Map<String, dynamic> viewsData;

  const ViewsSection({
    Key? key,
    required this.viewsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int totalViews = viewsData['totalViews'] ?? 0;
    final int monthlyViews = viewsData['monthlyViews'] ?? 0;
    final int lastMonthViews = viewsData['lastMonthViews'] ?? 0;
    final double viewsGrowth = viewsData['viewsGrowth'] ?? 0.0;
    final List<Map<String, dynamic>> viewsTimeline =
        (viewsData['viewsTimeline'] as List?)
            ?.map((item) => item as Map<String, dynamic>)
            .toList() ?? [];

    final Map<String, dynamic> insight = viewsData['insights']?['views'] ??
        {'status': 'moderate', 'message': 'No insights available'};

    final bool isPositiveGrowth = viewsGrowth >= 0;

    final headerTrailing = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositiveGrowth ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositiveGrowth ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositiveGrowth ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${viewsGrowth.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.montserrat(
              color: isPositiveGrowth ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return AnalyticsStatCard(
      title: 'Views Statistics',
      headerTrailing: headerTrailing,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly comparison
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'This Month',
                  monthlyViews.toString(),
                  const Color(0xff2e6f40),
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'Last Month',
                  lastMonthViews.toString(),
                  Colors.grey[700]!,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'All Time',
                  totalViews.toString(),
                  Colors.blue[700]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Monthly trend chart
          MonthlyTrendChart(monthlyData: viewsTimeline),

          const SizedBox(height: 20),

          // Insight message
          InsightMessage(
            message: insight['message'],
            status: _getInsightStatus(insight['status']),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
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