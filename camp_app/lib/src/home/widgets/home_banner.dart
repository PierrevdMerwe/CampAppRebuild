import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBanner extends StatelessWidget {
  final Color textColor;

  const HomeBanner({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        bottom: 16.0,
        right: 16.0,
      ),
      title: Container(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Campp',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'The Camp App',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      background: Image.asset(
        'images/homepage_banner.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}