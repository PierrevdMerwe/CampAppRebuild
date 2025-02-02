import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBanner extends StatelessWidget {
  final Color textColor;

  const HomeBanner({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.03,
          bottom: 16.0
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Campp',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'The Camp App',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
      background: Image.asset(
        'images/homepage_banner.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}