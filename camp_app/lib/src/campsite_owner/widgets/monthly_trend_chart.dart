// lib/src/campsite_owner/widgets/monthly_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyTrendChart({
    Key? key,
    required this.monthlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no data, show placeholder
    if (monthlyData.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Views Trend',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.show_chart,
            color: Color(0xff2e6f40),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'Monthly Views Trend',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Not enough data to display chart',
            style: GoogleFonts.montserrat(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    // Calculate min and max for y-axis
    final maxY = monthlyData.map((point) => point['views'] as int).reduce((a, b) => a > b ? a : b) * 1.2;
    const minY = 0.0;

    // Prepare spots and trend colors
    final List<FlSpot> spots = [];
    final List<Color> gradientColors = [];

    for (int i = 0; i < monthlyData.length; i++) {
      final currentViews = monthlyData[i]['views'] as int;
      spots.add(FlSpot(i.toDouble(), currentViews.toDouble()));

      // Add gradient color based on trend
      if (i > 0) {
        final previousViews = monthlyData[i-1]['views'] as int;
        final difference = currentViews - previousViews;

        if (difference > 0) {
          // Growth - green
          gradientColors.add(const Color(0xff2e6f40));
        } else if (difference == 0) {
          // No change - amber
          gradientColors.add(Colors.amber);
        } else {
          // Decline - red
          gradientColors.add(Colors.red);
        }
      } else {
        // First point - default to green
        gradientColors.add(const Color(0xff2e6f40));
      }
    }

    return LineChartData(
      // Remove grid for a more minimal look
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < monthlyData.length) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    monthlyData[index]['month'],
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              if (value == minY) {
                return const SizedBox();
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toInt().toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      // Removed border data for cleaner look
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: (monthlyData.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: gradientColors[index >= gradientColors.length ? gradientColors.length - 1 : index],
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withValues(alpha: 0.2)).toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // Improved tooltip styling
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipBorder: const BorderSide(
            color: Color(0xff2e6f40),
            width: 1,
          ),
          tooltipMargin: 8,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              final month = monthlyData[index]['month'];
              final views = monthlyData[index]['views'];

              return LineTooltipItem(
                '$month: $views views',
                GoogleFonts.montserrat(
                  color: const Color(0xff2e6f40),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchSpotThreshold: 20,
      ),
    );
  }
}