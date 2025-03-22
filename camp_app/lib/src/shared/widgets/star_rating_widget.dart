import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int totalStars;
  final double size;
  final Color color;
  final Color borderColor;
  final ValueChanged<int>? onRatingChanged;
  final EdgeInsets padding;
  final MainAxisAlignment alignment;

  const StarRating({
    Key? key,
    required this.rating,
    this.totalStars = 5,
    this.size = 24.0,
    this.color = const Color(0xFFFFD700), // Gold color for stars
    this.borderColor = const Color(0xFFAAAAAA), // Gray border for empty stars
    this.onRatingChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 2.0),
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: List.generate(totalStars, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Padding(
            padding: padding,
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? color : borderColor,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

class AnimatedStarRating extends StatefulWidget {
  final int initialRating;
  final int totalStars;
  final double size;
  final Color color;
  final Color borderColor;
  final ValueChanged<int> onRatingChanged;
  final EdgeInsets padding;
  final MainAxisAlignment alignment;

  const AnimatedStarRating({
    Key? key,
    this.initialRating = 0,
    this.totalStars = 5,
    this.size = 36.0,
    this.color = const Color(0xFFFFD700), // Gold color for stars
    this.borderColor = const Color(0xFFAAAAAA), // Gray border for empty stars
    required this.onRatingChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
    this.alignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  _AnimatedStarRatingState createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with SingleTickerProviderStateMixin {
  late int _rating;
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(
      widget.totalStars,
          (index) => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.5)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.5, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            index * 0.1 + 0.5,
            curve: Curves.linear,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateRating(int newRating) {
    if (_rating != newRating) {
      setState(() {
        _rating = newRating;
      });
      _controller.forward(from: 0.0);
      widget.onRatingChanged(newRating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.alignment,
      children: List.generate(widget.totalStars, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: index < _rating
                  ? _animations[index].value
                  : 1.0,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _updateRating(index + 1),
            child: Padding(
              padding: widget.padding,
              child: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: index < _rating ? widget.color : widget.borderColor,
                size: widget.size,
              ),
            ),
          ),
        );
      }),
    );
  }
}