import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../campsite/screens/campsite_search_screen.dart';

class CategoryGrid extends StatelessWidget {
  final Map<String, IconData> categories;
  final Map<String, Color> categoryColors;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == categories.length) {
            return _buildViewAllButton(context);
          }
          String category = categories.keys.elementAt(index);
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 150,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(category),
            ),
          ),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  categories[category],
                  size: 30,
                  color: categoryColors[category],
                ),
                Text(
                  category,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 150,
        child: Card(
          child: ElevatedButton(
            onPressed: () {
              // Add your onPressed function here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2e6f40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.arrow_forward, color: Colors.white),
                Text(
                  'All',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}