import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/rating_service.dart';
import 'comment_item_widget.dart';
import 'rating_dialog.dart';
import '../../shared/widgets/star_rating_widget.dart';

class CommentSection extends StatefulWidget {
  final String campsiteId;
  final String campsiteName;

  const CommentSection({
    Key? key,
    required this.campsiteId,
    required this.campsiteName,
  }) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final RatingService _ratingService = RatingService();
  bool _isLoading = true;
  bool _hasUserRated = false;
  List<Map<String, dynamic>> _comments = [];
  double _averageRating = 0.0;
  Map<String, dynamic>? _userRating;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the current user has already rated this campsite
      final hasRated = await _ratingService.hasUserRatedCampsite(widget.campsiteId);

      // Get the average rating for this campsite
      final avgRating = await _ratingService.getCampsiteAverageRating(widget.campsiteId);

      // Get all comments for this campsite
      final comments = await _ratingService.getCampsiteComments(widget.campsiteId);

      // Get the current user's rating if they've rated
      Map<String, dynamic>? userRating;
      if (hasRated) {
        userRating = await _ratingService.getUserRating(widget.campsiteId);
      }

      if (mounted) {
        setState(() {
          _hasUserRated = hasRated;
          _averageRating = avgRating;
          _comments = comments;
          _userRating = userRating;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RatingDialog(
          campsiteId: widget.campsiteId,
          campsiteName: widget.campsiteName,
          onRatingSubmitted: () {
            // Reload comments after a new rating is submitted
            _loadComments();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.grey)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Ratings and Comments',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2e6f40),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Average rating display
        if (!_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                StarRating(
                  rating: _averageRating.round(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_averageRating.toStringAsFixed(1)} out of 5',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_comments.length} ${_comments.length == 1 ? 'review' : 'reviews'})',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Rate button or user rating
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _hasUserRated
              ? _buildUserRatingInfo()
              : _buildRateButton(),
        ),

        const SizedBox(height: 16),

        // Comments list
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                color: Color(0xff2e6f40),
              ),
            ),
          )
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No reviews yet. Be the first to review!',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return CommentItem(comment: _comments[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.star, color: Colors.white),
        label: Text(
          'Rate this campsite',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2e6f40),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _showRatingDialog,
      ),
    );
  }

  Widget _buildUserRatingInfo() {
    if (_userRating == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff2e6f40).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xff2e6f40).withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xff2e6f40),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'You have already rated this campsite',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2e6f40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Your rating: ',
                style: GoogleFonts.montserrat(),
              ),
              StarRating(
                rating: _userRating!['rating'] ?? 0,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your review: ${_userRating!['comment'] ?? ''}',
            style: GoogleFonts.montserrat(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}