import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/star_rating_widget.dart';
import 'analytics_stat_card.dart';

class ReviewsSection extends StatelessWidget {
  final Map<String, dynamic> reviewsData;

  const ReviewsSection({
    Key? key,
    required this.reviewsData,
  }) : super(key: key);

  // Helper method to convert icon name to FontAwesome icon
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'tent':
        return FontAwesomeIcons.tent;
      case 'tree':
        return FontAwesomeIcons.tree;
      case 'campground':
        return FontAwesomeIcons.campground;
      case 'fire':
        return FontAwesomeIcons.fire;
      case 'mountain':
        return FontAwesomeIcons.mountain;
      case 'compass':
        return FontAwesomeIcons.compass;
      case 'shuttle-van':
        return FontAwesomeIcons.vanShuttle;
      case 'hiking':
        return FontAwesomeIcons.personHiking;
      case 'water':
        return FontAwesomeIcons.water;
      case 'fish':
        return FontAwesomeIcons.fish;
      case 'caravan':
        return FontAwesomeIcons.caravan;
      case 'binoculars':
        return FontAwesomeIcons.binoculars;
      default:
        return FontAwesomeIcons.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double averageRating = reviewsData['averageRating'] ?? 0.0;
    final int totalReviews = reviewsData['recentReviews']?.length ?? 0;
    final Map<String, dynamic> distribution = reviewsData['ratingDistribution'] ?? {};
    final List<dynamic> recentReviews = reviewsData['recentReviews'] ?? [];

    return AnalyticsStatCard(
      title: 'Ratings & Reviews',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (totalReviews > 0) _buildRatingOverview(averageRating, totalReviews, distribution)
          else _buildNoReviewsMessage(),

          const SizedBox(height: 24),

          // Recent reviews section
          Text(
            'Recent Reviews',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (recentReviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No reviews yet. Reviews will appear here as users leave them.',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                recentReviews.length,
                    (index) => _buildReviewItem(recentReviews[index], context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview(
      double averageRating,
      int totalReviews,
      Map<String, dynamic> distribution
      ) {
    // Calculate total number of reviews from distribution
    int totalFromDistribution = 0;
    distribution.forEach((key, value) {
      if (value is int) {
        totalFromDistribution += value;
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating column
        Column(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2e6f40),
              ),
            ),
            const SizedBox(height: 8),
            StarRating(
              rating: averageRating.round(),
              size: 20,
              color: const Color(0xFFFFD700),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalFromDistribution reviews',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        const SizedBox(width: 24),

        // Rating distribution
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating Distribution',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Using our reusable RatingDistributionBar widget
              RatingDistributionBar(
                rating: 5,
                count: distribution['5'] ?? 0,
                totalCount: totalFromDistribution,
              ),
              RatingDistributionBar(
                rating: 4,
                count: distribution['4'] ?? 0,
                totalCount: totalFromDistribution,
              ),
              RatingDistributionBar(
                rating: 3,
                count: distribution['3'] ?? 0,
                totalCount: totalFromDistribution,
              ),
              RatingDistributionBar(
                rating: 2,
                count: distribution['2'] ?? 0,
                totalCount: totalFromDistribution,
              ),
              RatingDistributionBar(
                rating: 1,
                count: distribution['1'] ?? 0,
                totalCount: totalFromDistribution,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoReviewsMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const FaIcon(
            FontAwesomeIcons.comments,
            color: Color(0xff2e6f40),
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your campsite hasn\'t received any reviews yet. Reviews will appear here once customers rate your campsite.',
            style: GoogleFonts.montserrat(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review, BuildContext context) {
    final String username = review['username'] ?? 'Anonymous';
    final String comment = review['comment'] ?? '';
    final int rating = review['rating'] ?? 0;

    // Format the timestamp
    String formattedDate = '';
    if (review['createdAt'] is Timestamp) {
      final timestamp = review['createdAt'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());
    }

    // Get profile icon data
    Map<String, dynamic>? profileData = review['profile'];
    final String backgroundColor = profileData != null
        ? profileData['background'] ?? 'FF2E6F40'
        : 'FF2E6F40';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEFFF5), // Light green background for reviews
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: profileData != null
                        ? Color(int.parse('0x$backgroundColor'))
                        : const Color(0xffe3e3e3), // Fallback to light gray if no profile
                  ),
                  child: Center(
                    child: profileData != null
                        ? FaIcon(
                      _getIconData(profileData['icon'] ?? 'user'),
                      color: Colors.white,
                      size: 16,
                    )
                        : const FaIcon(
                      FontAwesomeIcons.user,
                      color: Colors.black54,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Username and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                // Rating
                StarRating(
                  rating: rating,
                  size: 16,
                ),
              ],
            ),
            if (comment.isNotEmpty) const SizedBox(height: 8),
            if (comment.isNotEmpty)
              Text(
                comment,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}