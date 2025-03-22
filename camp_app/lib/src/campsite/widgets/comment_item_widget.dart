import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/star_rating_widget.dart';
import '../../core/services/profile_icon_service.dart';

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;

  const CommentItem({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final ProfileIconService _profileIconService = ProfileIconService();
  bool _isLoadingIcon = true;
  Map<String, dynamic>? _profileIconData;

  @override
  void initState() {
    super.initState();
    _loadProfileIcon();
  }

  Future<void> _loadProfileIcon() async {
    setState(() {
      _isLoadingIcon = true;
    });

    try {
      // Check if profile icon data is already in the comment
      if (widget.comment.containsKey('profile') &&
          widget.comment['profile'] != null) {
        setState(() {
          _profileIconData = widget.comment['profile'];
          _isLoadingIcon = false;
        });
      } else {
        setState(() {
          _profileIconData = null;
          _isLoadingIcon = false;
        });
      }
    } catch (e) {
      print('Error loading profile icon: $e');
      setState(() {
        _isLoadingIcon = false;
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      return DateFormat('MMM d, yyyy').format(dateTime);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile icon, username, and rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isLoadingIcon
                        ? const Color(0xff2e6f40)
                        : _profileIconData != null
                        ? Color(int.parse("0x${_profileIconData!['background'] ?? 'FF2E6F40'}"))
                        : const Color(0xff2e6f40),
                    shape: BoxShape.circle,
                  ),
                  child: _isLoadingIcon
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : _profileIconData != null
                      ? Center(
                    child: FaIcon(
                      _profileIconService.getIconData(
                        _profileIconData!['icon'],
                      ),
                      size: 20,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),

                // Username and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment['username'] ?? 'Anonymous',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StarRating(
                            rating: widget.comment['rating'] ?? 0,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(widget.comment['createdAt']),
                            style: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Comment text
            const SizedBox(height: 16),
            Text(
              widget.comment['comment'] ?? '',
              style: GoogleFonts.montserrat(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}